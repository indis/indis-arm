matcher :thumb do |instr, bytes|
  opcode = bytes >> 11
  if opcode == 0b11101 || opcode == 0b11110 || opcode == 0b11111
    instr.size = 4
    match :thumb32, instr, bytes
  else
    instr.size = 2
    match :thumb16, instr, bytes
  end
end

matcher :thumb => :thumb16 do |instr, bytes|
  opcode6 = bytes >> 10
  case opcode6
  when 0b010000
    match :data_processing, instr, bytes
  when 0b010001
    match :spec_data_bx, instr, bytes
  else
    opcode5 = opcode6 >> 1
    case opcode5
    when 0b01001
      match :ldr_literal, instr, bytes
    when 0b10100
      common :add_reg_immed, instr, bytes, 'adr', 'pc'
    when 0b10101
      common :add_reg_immed, instr, bytes, 'add', 'sp'
      instr.sets_flags = false
    when 0b11000
      match :stm, instr, bytes
    when 0b11001
      match :ldm, instr, bytes
    when 0b11100
      match :b, instr, bytes
    else
      opcode4 = opcode5 >> 1
      case opcode4
      when 0b0101
        match :ldr_single, instr, bytes
      when 0b1011
        match :misc, instr, bytes
      when 0b1101
        match :b_svc, instr, bytes
      else
        opcode3 = opcode4 >> 1
        case opcode3
        when 0b011, 0b100
          match :ldr_single, instr, bytes
        else
          opcode2 = opcode3 >> 1
          if opcode2 == 0
            match :shift_add_sub_mov_cmp, instr, bytes
          else
            raise UnknownInstructionError
          end
        end
      end
    end
  end
end

common :it_conditional do |instr, bytes| # lazy
  instr.mnemonic += instr.it_mnemonic
end

####

matcher :thumb16 => :shift_add_sub_mov_cmp do |instr, bytes|
  opcode5 = (bytes >> 9) & 0b11111
  opcode3 = opcode5 >> 2
  
  # cmp does not have sets_flags_ouside_of_it, other do
  if opcode3 == 0b101
    match :cmp_imm, instr, bytes
  else
    common :sets_flags_ouside_of_it, instr, bytes
    
    case opcode5
    when 0b01100
      match :add_reg, instr, bytes
    when 0b01101
      match :sub_reg, instr, bytes
    when 0b01110
      match :add_imm3, instr, bytes
    when 0b01111
      match :sub_imm3, instr, bytes
    else
      case opcode3
      when 0b000
        match :lsl_imm, instr, bytes
      when 0b001
        common :shift_imm5, instr, bytes, 'lsr', '01'
      when 0b010
        common :shift_imm5, instr, bytes, 'asr', '10'
      when 0b100
        match :mov_imm, instr, bytes
      # when 0b101
      #   match :cmp_imm, instr, bytes
      when 0b110
        match :add_imm8, instr, bytes
      when 0b111
        match :sub_imm8, instr, bytes
      else
        raise UnknownInstructionError
      end
    end
  end
end

common :imm5_Rm_Rd do |instr, bytes|
  rd   = bytes        & 0b111
  rm   = (bytes >> 3) & 0b111
  imm5 = (bytes >> 6) & 0b11111
  instr.values = { rd: rd, rm: rm, imm5: imm5 }
  instr.operands = '{{rd}}, {{rm}}, #{{imm5}}'
end

common :sets_flags_ouside_of_it do |instr, bytes|
  if instr.in_it?
    instr.mnemonic += instr.it_mnemonic
    instr.sets_flags = false
  else
    instr.mnemonic += 's'
    instr.sets_flags = true
  end
end

common :shift_imm5 do |instr, bytes, name, decode_shift|
  instr.mnemonic = name + instr.mnemonic
  common :imm5_Rm_Rd, instr, bytes
  instr.values[:shift_n] = h.DecodeImmShift(decode_shift, instr.values[:imm5])
end

matcher :shift_add_sub_mov_cmp => :lsl_imm do |instr, bytes|
  imm5 = (bytes >> 6) & 0b11111
  if imm5 == 0
    match :movs, instr, bytes
  else
    common :shift_imm5, instr, bytes, 'lsl', '00'
  end
end

matcher :lsl_imm => :movs do |instr, bytes|
  rd   = bytes        & 0b111
  rm   = (bytes >> 3) & 0b111
  raise UnpredictableError if instr.in_it?
  instr.mnemonic = 'movs'
  instr.values = { rd: rd, rm: rm }
  instr.operands = '{{rd}}, {{rm}}'
end

common :Rm_Rn_Rd do |instr, bytes|
  rd = bytes        & 0b111
  rn = (bytes >> 3) & 0b111
  rm = (bytes >> 6) & 0b111
  instr.values = { rd: rd, rm: rm, rn: rn }
  instr.operands = '{{rd}}, {{rn}}, {{rm}}'
end

matcher :shift_add_sub_mov_cmp => :add_reg do |instr, bytes|
  instr.mnemonic = 'add' + instr.mnemonic
  common :Rm_Rn_Rd, instr, bytes
end

matcher :shift_add_sub_mov_cmp => :sub_reg do |instr, bytes|
  instr.mnemonic = 'sub' + instr.mnemonic
  common :Rm_Rn_Rd, instr, bytes
end

common :imm3_Rn_Rd do |instr, bytes|
  rd    = bytes        & 0b111
  rn    = (bytes >> 3) & 0b111
  imm3  = (bytes >> 6) & 0b111
  imm32 = h.ZeroExtend(imm3, 32)
  instr.values = { rd: rd, rn: rn, imm3: imm3, imm32: imm32 }
  instr.operands = '{{rd}}, {{rn}}, #{{imm3}}'
end

matcher :shift_add_sub_mov_cmp => :add_imm3 do |instr, bytes|
  instr.mnemonic = 'add' + instr.mnemonic
  common :imm3_Rn_Rd, instr, bytes
end

matcher :shift_add_sub_mov_cmp => :sub_imm3 do |instr, bytes|
  instr.mnemonic = 'sub' + instr.mnemonic
  common :imm3_Rn_Rd, instr, bytes
end

common :reg_imm8zx do |instr, bytes, regn|
  rr    = (bytes >> 8) & 0b111
  imm8  = bytes        & 0b11111111
  imm32 = h.ZeroExtend(imm8, 32)
  instr.values = { regn => rr, imm8: imm8, imm32: imm32 }
  instr.operands = "{{#{regn}}}, \#{{imm8}}"
end

matcher :shift_add_sub_mov_cmp => :mov_imm do |instr, bytes|
  instr.mnemonic = 'mov' + instr.mnemonic
  common :reg_imm8zx, instr, bytes, :rd
  # TODO: carry = APSR.C
end

matcher :shift_add_sub_mov_cmp => :cmp_imm do |instr, bytes|
  instr.mnemonic = 'cmp' + instr.it_mnemonic
  common :reg_imm8zx, instr, bytes, :rn
end

matcher :shift_add_sub_mov_cmp => :add_imm8 do |instr, bytes|
  instr.mnemonic = 'add' + instr.mnemonic
  common :reg_imm8zx, instr, bytes, :rdn
end

matcher :shift_add_sub_mov_cmp => :sub_imm8 do |instr, bytes|
  instr.mnemonic = 'sub' + instr.mnemonic
  common :reg_imm8zx, instr, bytes, :rdn
end

####

matcher :thumb16 => :data_processing do |instr, bytes|
  opcode4 = (bytes >> 6) & 0b1111
  case opcode4
  when 0b1010
    common :cmp_cmn_2regs, instr, bytes, 'cmp'
  when 0b1011
    common :cmp_cmn_2regs, instr, bytes, 'cmn'
  when 0b1000
    common :cmp_cmn_2regs, instr, bytes, 'tst'
  else
    common :sets_flags_ouside_of_it, instr, bytes
    case opcode4
    when 0b0000
      common :data_processing_shifts, instr, bytes, 'and'
    when 0b0001
      common :data_processing_shifts, instr, bytes, 'eor'
    when 0b0010
      common :data_processing_no_shifts, instr, bytes, 'lsl'
    when 0b0011
      common :data_processing_no_shifts, instr, bytes, 'lsr'
    when 0b0100
      common :data_processing_no_shifts, instr, bytes, 'asr'
    when 0b0101
      common :data_processing_shifts, instr, bytes, 'adc'
    when 0b0110
      common :data_processing_shifts, instr, bytes, 'sbc'
    when 0b0111
      common :data_processing_no_shifts, instr, bytes, 'ror'
    when 0b1001
      match :rsb, instr, bytes
    when 0b1100
      common :data_processing_shifts, instr, bytes, 'orr'
    when 0b1101
      match :mul, instr, bytes
    when 0b1110
      common :data_processing_shifts, instr, bytes, 'bic'
    when 0b1111
      common :data_processing_shifts, instr, bytes, 'mvn'
    end
  end
end

common :cmp_cmn_2regs do |instr, bytes, name|
  rm = (bytes >> 3) & 0b111
  rn = bytes        & 0b111
  instr.mnemonic = name + instr.it_mnemonic
  instr.values = { rm: rm, rn: rn }
  instr.operands = '{{rn}}, {{rm}}'
end

common :data_processing_shifts do |instr, bytes, name|
  common :data_processing_no_shifts, instr, bytes, name
  instr.values[:shift_t] = :lsl
  instr.values[:shift_n] = 0
end

common :data_processing_no_shifts do |instr, bytes, name|
  rm  = (bytes >> 3) & 0b111
  rdn = bytes        & 0b111
  instr.mnemonic = name + instr.mnemonic
  instr.values = { rm: rm, rn: rdn, rd: rdn, rdn: rdn }
  instr.operands = '{{rdn}}, {{rm}}'
end

matcher :data_processing => :rsb do |instr, bytes|
  rn = (bytes >> 3) & 0b111
  rd = bytes        & 0b111
  instr.mnemonic = 'rsb' + instr.mnemonic
  instr.values = { rn: rn, rd: rd, imm32: 0 }
  instr.operands = '{{rd}}, {{rn}}, #{{imm32}}'
end

matcher :data_processing => :mul do |instr, bytes|
  rn  = (bytes >> 3) & 0b111
  rdm = bytes        & 0b111
  instr.mnemonic = 'mul' + instr.mnemonic
  instr.values = { rn: rn, rd: rdm, rdm: rdm }
  instr.operands = '{{rdm}}, {{rn}}, {{rdm}}'
  # TODO: if ArchVersion() < 6 && d == n then UNPREDICTABLE
end

matcher :thumb16 => :spec_data_bx do |instr, bytes|
  opcode4 = (bytes >> 6) & 0b1111
  case opcode4
  when 0b0000
    match :add, instr, bytes # low
  when 0b0001, 0b0010, 0b0011
    match :add, instr, bytes # high
  when 0b0100
    raise UnpredictableError
  when 0b0101, 0b0110, 0b0111
    match :cmp, instr, bytes
  when 0b1000
    match :mov, instr, bytes # low
  when 0b1001, 0b1010, 0b1011
    match :mov, instr, bytes # high
  when 0b1100, 0b1101
    common :bx_blx, instr, bytes, 'bx'
  when 0b1110, 0b1111
    common :bx_blx, instr, bytes, 'blx'
    raise UnpredictableError if instr.values[:rm] == 15
  end
end

matcher :spec_data_bx => :add do |instr, bytes|
  dn  = (bytes >> 7) & 0b1
  rm  = (bytes >> 3) & 0b1111
  rdn = bytes        & 0b111
  d   = (dn << 3) + rdn
  
  match :add_sp, instr, bytes if d == 0b1101 || rm == 0b1101 # SEE ADD (SP plus register)
  raise UnpredictableError if d == 15 && rm == 15
  raise UnpredictableError if d == 15 && instr.in_it? && instr.position_in_it != 4
  instr.mnemonic = 'add' + instr.it_mnemonic
  instr.values = { rd: d, rn: d, rdn: d, rm: rm, shift_t: :lsl, shift_n: 0 }
  instr.operands = '{{rdn}}, {{rm}}'
  instr.sets_flags = false
end

matcher :add => :add_sp do |instr, bytes|
  # TODO: implement?
end

matcher :spec_data_bx => :cmp do |instr, bytes|
  # FIXME: merge with :spec_data_bx => :add
  n1 = (bytes >> 7) & 0b1
  rm = (bytes >> 3) & 0b1111
  rn = bytes        & 0b111
  n  = (n1 << 3) + rn
  
  raise UnpredictableError if n < 8 && rm < 8
  raise UnpredictableError if n == 15 && rm == 15
  instr.mnemonic = 'cmp' + instr.it_mnemonic
  instr.values = { rm: rm, rn: n, shift_t: :lsl, shift_n: 0 }
  instr.operands = '{{rn}}, {{rm}}'
end

matcher :spec_data_bx => :mov do |instr, bytes|
  # FIXME: merge with :spec_data_bx => :add
  d1 = (bytes >> 7) & 0b1
  rm = (bytes >> 3) & 0b1111
  rd = bytes        & 0b111
  d  = (d1 << 3) + rd
  
  raise UnpredictableError if d == 15 && instr.in_it? && instr.position_in_it != 4
  instr.sets_flags = false
  instr.mnemonic = 'mov' + instr.it_mnemonic
  instr.values = { rd: d, rm: rm }
  instr.operands = '{{rd}}, {{rm}}'
end

common :bx_blx do |instr, bytes, name|
  rm = (bytes >> 3) & 0b1111
  raise UnpredictableError if instr.in_it? && instr.position_in_it != 4
  instr.mnemonic = name + instr.it_mnemonic
  instr.values = { rm: rm }
  instr.operands = '{{rm}}'
end

####

matcher :thumb16 => :ldr_literal do |instr, bytes|
  rt   = (bytes >> 8) & 0b111
  imm8 = bytes & 0b11111111
  imm32 = h.ZeroExtend(imm8 << 2, 32)
  instr.mnemonic = 'ldr' + instr.it_mnemonic
  instr.values = { rt: rt, imm8: imm8, imm32: imm32, add: true }
  instr.operands = '{{rt}}, [pc, #{{imm32}}]'
end

####

matcher :thumb16 => :ldr_single do |instr, bytes|
  opA = (bytes >> 12) & 0b1111
  opB3 = (bytes >> 9)  & 0b111
  opB1 = opB3 >> 2
  case opA
  when 0b0101
    names = %w(str strh strb ldrsb ldr ldrh ldrb ldrsh)
    common :Rm_Rn_Rt_data_load, instr, bytes, names[opB]
  when 0b0110
    common :imm5_Rn_Rt_data_load, instr, bytes, (opB1 == 0 ? 'str' : 'ldr'), 2
  when 0b0111
    common :imm5_Rn_Rt_data_load, instr, bytes, (opB1 == 0 ? 'strb' : 'ldrb'), 0
  when 0b1000
    common :imm5_Rn_Rt_data_load, instr, bytes, (opB1 == 0 ? 'strh' : 'ldrh'), 1
  when 0b1001
    instr.mnemonic = (opB1 == 0 ? 'str' : 'ldr') + instr.it_mnemonic
    match :data_load_sprel, instr, bytes
  else
    raise UnknownInstructionError
  end
end

common :Rm_Rn_Rt_data_load do |instr, bytes, name|
  rt = bytes        & 0b111
  rn = (bytes >> 3) & 0b111
  rm = (bytes >> 6) & 0b111
  instr.mnemonic = name + instr.it_mnemonic
  instr.values = { rt: rt, rn: rn, rm: rm, index: true, add: true, wback: false, shift_t: :lsl, shift_n: 0 }
  instr.operands = '{{rt}}, [{{rn}}, {{rm}}]'
end

common :imm5_Rn_Rt_data_load do |instr, bytes, name, shl|
  rt   = bytes        & 0b111
  rn   = (bytes >> 3) & 0b111
  imm5 = (bytes >> 6) & 0b11111
  imm32 = h.ZeroExtend(imm5 << shl, 32)
  instr.mnemonic = name + instr.it_mnemonic
  instr.values = { rt: rt, rn: rn, imm5: imm5, imm32: imm32, index: true, add: true, wback: false }
  instr.operands = imm32 == 0 ? '{{rt}}, [{{rn}}]' : '{{rt}}, [{{rn}}, #{{imm32}}]'
end

matcher :ldr_single => :data_load_sprel do |instr, bytes|
  rt   = (bytes >> 8) & 0b111
  imm8 = bytes        & 0b11111111
  imm32 = h.ZeroExtend(imm8 << 2, 32)
  instr.values = { rt: rt, imm8: imm8, imm32: imm32, index: true, add: true, wback: false, rn: 13 }
  instr.operands = '{{rt}}, [sp, #{{imm32}}]'
end

####

common :add_reg_immed do |instr, bytes, name, regn|
  rd   = (bytes >> 8) & 0b111
  imm8 = bytes        & 0b11111111
  imm32 = h.ZeroExtend(imm8 << 2, 32)
  instr.values rd: rd, imm8: imm8, imm32: imm32, add: true, rn: regn
  instr.mnemonic = name + instr.it_mnemonic
  instr.operands = '{{rd}}, {{rn}}, #{{imm32}}'
end

####

matcher :thumb16 => :misc do |instr, bytes|
  opcode7 = (bytes >> 5) & 0b1111111
  case opcode7
  when 0b0110010
    match :setend, instr, bytes
  when 0b0110011
    match :cps, instr, bytes
  else
    opcode6 = opcode7 >> 1
    case opcode6
    when 0b001000
      common :sxt_rd_rm, instr, bytes, 'sxth'
    when 0b001001
      common :sxt_rd_rm, instr, bytes, 'sxtb'
    when 0b001010
      common :sxt_rd_rm, instr, bytes, 'uxth'
    when 0b001011
      common :sxt_rd_rm, instr, bytes, 'uxtb'
    when 0b101000
      common :sxt_rd_rm, instr, bytes, 'rev'
    when 0b101001
      common :sxt_rd_rm, instr, bytes, 'rev16'
    when 0b10111
      common :sxt_rd_rm, instr, bytes, 'revsh'
    else
      opcode5 = opcode6 >> 1
      case opcode5
        when 0b00000
          common :addsub_sp_imm, instr, bytes, 'add'
        when 0b00001
          common :addsub_sp_imm, instr, bytes, 'sub'
        else
          opcode4 = opcode5 >> 1
          case opcode4
          when 0b0001, 0b0011, 0b1001, 0b1011
            match :cbz_cbnz, instr, bytes
          when 0b1110
            match :bkpt, instr, bytes
          when 0b1111
            match :ifthen, instr, bytes
          else
            opcode3 = opcode4 >> 1
            case opcode3
            when 0b010
              match :push, instr, bytes
            when 0b110
              match :pop, instr, bytes
            end
          end
      end
    end
  end
end

matcher :misc => :setend do |instr, bytes|
  e = (bytes >> 3) & 0b1
  instr.name = 'setend'
  instr.values = { e: e }
  instr.operands = e == 1 ? 'big' : 'little'
  raise UnpredictableError if instr.in_it?
end

matcher :misc => :cps do |instr, bytes|
  im = (bits >> 4) & 0b1
  a  = (bits >> 2) & 0b1
  i  = (bits >> 1) & 0b1
  f  = bits        & 0b1
  
  raise UnpredictableError if a+i+f == 0
  enable = im == 0
  changemode = false
  
  instr.mnemonic = 'cps' + (enable ? 'ie' : 'id')
  instr.values = { enable: enable, a: (a == 1), i: (i == 1), f: (f == 1) }
  instr.operands = (a == 1 ? 'a' : '') + (i == 1 ? 'i' : '') + (f == 1 ? 'f' : '')
  
  raise UnpredictableError if instr.in_it?
end

common :sxt_rd_rm do |instr, bytes, name|
  rd = bytes        & 0b111
  rm = (bytes >> 3) & 0b111
  instr.mnemonic = name + instr.it_mnemonic
  instr.values = { rd: rd, rm: rm, rotation: 0 }
  instr.operands = '{{rd}}, {{rm}}'
end

common :addsub_sp_imm do |instr, bytes, name|
  imm7 = bytes & 0b1111111
  imm32 = h.ZeroExtend(imm8 << 2, 32)
  instr.sets_flags = false
  instr.values rd: 13, imm7: imm7, imm32: imm32
  instr.mnemonic = name + instr.it_mnemonic
  instr.operands = 'sp, sp, #{{imm32}}'
end

matcher :misc => :cbz_cbnz do |instr, bytes|
  rn   = bytes         & 0b111
  imm5 = (bytes >> 3)  & 0b11111
  op   = (bytes >> 11) & 0b1
  i    = (bytes >> 9)  & 0b1
  nonzero = op == 1
  imm32 = h.ZeroExtend((i << 6) + (imm5 << 1), 32)
  raise UnpredictableError if instr.in_it?
  instr.mnemonic = nonzero ? 'cbnz' : 'cbz'
  instr.values = { rn: rn, imm5: imm5, imm32: imm32, nonzero: nonzero }
  instr.operands = '{{rn}}, pc, #{{imm32}}'
end

matcher :misc => :bkpt do |instr, bytes|
  imm8 = bytes & 0b11111111
  instr.mnemonic = 'bkpt'
  instr.values = { imm8: imm8 }
  instr.operands '#{{imm8}}'
end

matcher :misc => :ifthen do |instr, bytes|
  opA = (bytes >> 4) & 0b1111
  opB = bytes        & 0b1111
  if opB == 0
    names = %w(nop yield wfe wfi sev)
    name = names[opA]
    raise UnknownInstructionError unless name
    instr.mnemonic = name + instr.it_mnemonic
  else
    match :it, instr, bytes
  end
end

matcher :ifthen => :it do |instr, bytes|
  first_cond = (bytes >> 4) & 0b1111
  mask       = bytes        & 0b1111
  raise BadMatchError if mask == 0
  raise UnpredictableError if first_cond == 0b1111 || (first_cond == 0b1110 && mask.bit_count != 1) # FIXME implement
  raise UnpredictableError if instr.in_it?
  
  first_cond_0 = first_cond & 0b1
  conditions = [first_cond]
  cond_count = 1
  xyz = []
  
  if mask & 0b111 == 0b100
    cond_count = 2
  elsif mask & 0b11 == 0b10
    cond_count = 3
  elsif mask & 0b1 == 0b1
    cond_count = 4
  end
  
  (cond_count-1).times do |i|
    mask_bit = (mask >> (3-i)) & 0b1
    if mask_bit == first_cond_0
      xyz << 't'
      conditions << first_cond
    else
      xyz << 'e'
      conditions << (first_cond ^ 0b1)
    end
  end
  
  conditions = conditions.map { |cond| h.cond_to_mnemonic(cond) }
  
  instr.mnemonic = 'it' + xyz.join('')
  instr.values = { first_cond: h.cond_to_mnemonic(first_cond), conditions: conditions }
  instr.operands = '{{first_cond}}'
end

common :pushpopregs do |instr, bytes|
  registers = (bytes & 0b11111111)
  registers = registers.to_s(2).split('').each_with_index.map { |val,idx| val == "1" ? idx : nil }.compact
  raise UnpredictableError if registers.length < 1
  instr.values = { registers: registers }
end

matcher :misc => :push do |instr, bytes|
  m = (bytes >> 8) & 0b1
  common :pushpopregs, instr, bytes
  instr.values[:registers] << 14 if m
  instr.values[:unaligned_allowed] = false
  instr.mnemonic = 'push' + instr.it_mnemonic
  insr.operands = '{{unwind_regs_a:registers}}'
end

matcher :misc => :pop do |instr, bytes|
  p = (bytes >> 8) & 0b1
  common :pushpopregs, instr, bytes
  instr.values[:registers] << 15 if p
  instr.values[:unaligned_allowed] = false
  instr.mnemonic = 'push' + instr.it_mnemonic
  insr.operands = '{{unwind_regs_a:registers}}'
  raise UnpredictableError if p == 1 && instr.in_it? && instr.position_in_it != 4
end

common :stmldm do |instr, bytes, name|
  rn = (bytes >> 8) & 0b111
  common :pushpopregs, instr, bytes
  instr.mnemonic = name + instr.it_mnemonic
  instr.values[:rn] = rn
  instr.operands = '{{rn}}!, {{unwind_regs_a:registers}}'
end

matcher :thumb16 => :stm do |instr, bytes|
  common :stmldm, instr, bytes, 'stm'
  instr.values[:wback] = true
end

matcher :thumb16 => :ldm do |instr, bytes|
  common :stmldm, instr, bytes, 'stm'
  wback = instr.values[:registers].include?(instr.values[:rn])
  instr.operands = '{{rn}}{{iftrue:wback{!,}]}}, {{unwind_regs_a:registers}}'
end

matcher :thumb16 => :b_svc do |instr, bytes|
  opcode4 = (bytes >> 8) & 0b1111
  opcode3 = opcode4 >> 1
  if opcode3 == 0b111
    if opcode4 & 0b1 == 1
      match :svc, instr, bytes
    else
      match :undef, instr, bytes
    end
  else
    match :cond_b, instr, bytes
  end
end

common :imm8_only_zeroexpand do |instr, bytes|
  imm8 = bytes & 0b11111111
  imm32 = h.ZeroExtend(imm8, 32)
  instr.values = { imm8: imm8, imm32: imm32 }
  instr.operands = '{{imm32}}'
end

matcher :b_svc => :svc do |instr, bytes|
  common :imm8_only_zeroexpand, instr, bytes
  instr.mnemonic = 'svc' + instr.it_mnemonic
end

matcher :b_svc => :undef do |instr, bytes|
  common :imm8_only_zeroexpand, instr, bytes
  instr.mnemonic = 'udf' + instr.it_mnemonic
end

matcher :b_svc => :cond_b do |instr, bytes|
  cond = (bytes >> 8) & 0b1111
  imm8 = bytes & 0b11111111
  imm32 = h.SignExtend(imm8 << 1, 32)
  
  raise UnpredictableError if instr.in_it?
  
  instr.mnemonic = 'b' + h.cond_to_mnemonic(cond)
  instr.values = { imm8: imm8, imm32: imm32 }
  instr.operands = '{{imm32}}'
end

matcher :thumb16 => :b do |instr, bytes|
  imm11 = bytes & 0b11111111111
  imm32 = h.SignExtend(imm11 << 1, 32)
  
  raise UnpredictableError if instr.in_it? && instr.position_in_it != 4
  
  instr.mnemonic = 'b' + instr.it_mnemonic
  instr.values = { imm11: imm11, imm32: imm32 }
  instr.operands = '{{imm32}}'
end
