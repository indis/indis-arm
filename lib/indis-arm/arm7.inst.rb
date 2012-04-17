##############################################################################
#   Indis framework                                                          #
#   Copyright (C) 2012 Vladimir "Farcaller" Pouzanov <farcaller@gmail.com>   #
#                                                                            #
#   This program is free software: you can redistribute it and/or modify     #
#   it under the terms of the GNU General Public License as published by     #
#   the Free Software Foundation, either version 3 of the License, or        #
#   (at your option) any later version.                                      #
#                                                                            #
#   This program is distributed in the hope that it will be useful,          #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#   GNU General Public License for more details.                             #
#                                                                            #
#   You should have received a copy of the GNU General Public License        #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.    #
##############################################################################

instruction :ADD do # 8.8.4-11
  encoding :T1_imm
  encoding :T2_imm
  encoding :T3_imm
  encoding :T4_imm
  encoding :A1_imm do
    attrs :cond, :Rd, :Rn, :imm, :setflags
    bits 'CCCC0010100Snnnnddddiiiiiiiiiiii', 'i' => :imm12
    format value: '#{@Rd}, #{@Rn}, ##{@imm}'
    process do |k|
      raise Indis::ARM::NotThisInstructionError if k.Rn == 0b1111 && k.setflags == 0 # ADR
      raise Indis::ARM::NotThisInstructionError if k.Rn == 0b1101 # ADD:spimm
      raise Indis::ARM::NotThisInstructionError if k.Rd == 0b1111 && k.setflags == 1 # SUBS PC, LR
      @imm = h.ARMExpandImm(k.imm12.to_boz(12)).to_i
    end
  end
  encoding :T1_reg
  encoding :T2_reg
  encoding :A1_reg do
    attrs :cond, :Rd, :Rn, :Rm, :imm, :setflags, :imm_shift
    bits 'CCCC0000100SnnnnddddiiiiiTT0mmmm', 'i' => :imm5, 'T' => :type
    format value: '#{@Rd}, #{@Rn}, #{@Rm}#{@imm > 0 ? ", #{h.shift_type_to_s(@imm_shift)} ##{@imm}" : "" }'
    process do |k|
      # FIXME: mnemonic is wrong?
      raise Indis::ARM::NotThisInstructionError if k.Rd == 0b1111 && k.setflags == 1 # SUBS PC, LR
      raise Indis::ARM::NotThisInstructionError if k.Rn == 0b1101 # ADD:spreg
      (@imm_shift, @imm) = h.DecodeImmShift(k.type.to_bo, k.imm5.to_bo)
      @imm = @imm.to_i
    end
  end
  encoding :A1_rsr
  encoding :T1_spimm
  encoding :T2_spimm
  encoding :T3_spimm
  encoding :T4_spimm
  encoding :A1_spimm do
    attrs :cond, :Rd, :imm, :setflags
    bits 'CCCC0010100S1101ddddiiiiiiiiiiii', 'i' => :imm12
    format value: '#{@Rd}, sp, ##{@imm}'
    process do |k|
      raise Indis::ARM::NotThisInstructionError if k.Rd == 0b1111 && k.setflags == 1 # SUBS PC, LR
      @imm = h.ARMExpandImm(k.imm12.to_boz(12)).to_i
    end
  end
  encoding :T1_spreg
  encoding :T2_spreg
  encoding :T3_spreg
  encoding :A1_spreg
end

instruction :B do # 8.8.18
  encoding :T1
  encoding :T2
  encoding :T3
  encoding :T4
  encoding :A1 do
    attrs :cond, :imm, :branch_address
    bits 'CCCC1010iiiiiiiiiiiiiiiiiiiiiiii', 'i' => :imm24
    format value:       '##{@imm}',
           value_const: '#{sprintf("0x%x", @branch_address)}'
    process do |k|
      @imm = h.SignExtend(k.imm24.to_boz(24) << 2, 32).to_signed_i
      @value_format = :value_const
      @branch_address = @vmaddr+8+@imm
    end
  end
end

instruction :BIC do # 8.8.21
  encoding :T1_imm
  encoding :A1_imm do
    attrs :cond, :setflags, :Rn, :Rd, :imm
    bits 'CCCC0011110Snnnnddddiiiiiiiiiiii', 'i' => :imm12
    format value: '#{@Rd}, #{@Rn}, ##{@imm}'
    process do |k|
      (@imm, @carry) = h.ARMExpandImm_C(k.imm12.to_boz(12), 0) # TODO: APSR.C ?
      @imm = @imm.to_i
    end
  end
  encoding :T1_reg
  encoding :T2_reg
  encoding :A1_reg do
    attrs :cond, :setflags, :Rn, :Rd, :Rm, :imm, :imm_shift
    bits 'CCCC0001110SnnnnddddiiiiiTT0mmmm', 'i' => :imm5, 'T' => :type
    format value: '#{@Rd}, #{@Rn}, #{@Rm}#{@imm > 0 ? ", #{h.shift_type_to_s(@imm_shift)} ##{@imm}" : "" }'
    process do |k|
      raise Indis::ARM::NotThisInstructionError if k.Rd = 0b1111 && k.setflags == 1 # SUBS PC, LR
      (@imm_shift, @imm) = h.DecodeImmShift(k.type.to_bo, k.imm5.to_bo)
      @imm = @imm.to_i
    end
  end
  encoding :A1_rsr
end

instruction :BL do # 8.8.25
  encoding :T1
  encoding :T2
  encoding :A1 do
    attrs :cond, :imm, :target_instr_set, :branch_address
    bits 'CCCC1011iiiiiiiiiiiiiiiiiiiiiiii', 'i' => :imm24
    format value:       '##{@imm}',
           value_const: '#{sprintf("0x%x", @branch_address)}'
    process do |k|
      @imm = h.SignExtend(k.imm24.to_boz(24) << 2, 32).to_signed_i
      @target_instr_set = :arm
      @value_format = :value_const
      @branch_address = @vmaddr+8+@imm
    end
  end
  encoding :A2 do
    attrs :imm, :target_instr_set, :branch_address
    bits '1111101Hiiiiiiiiiiiiiiiiiiiiiiii', 'i' => :imm24, 'H' => :h
    format operator:    'BLX',
           value:       '##{@imm}',
           value_const: '#{sprintf("0x%x", @branch_address)}'
    process do |k|
      # FIXME what is H used for?..
      @imm = h.SignExtend(k.imm24.to_boz(24) << 2, 32).to_signed_i
      @target_instr_set = :thumb
      @value_format = :value_const
      @branch_address = @vmaddr+8+@imm
    end
  end
end

instruction :CMP do # 8.8.37-39
  encoding :T1_imm
  encoding :T2_imm
  encoding :A1_imm do
    attrs :cond, :Rn, :imm
    bits 'CCCC00110101nnnn0000iiiiiiiiiiii', 'i' => :imm12
    format value: '#{@Rn}, ##{@imm}'
    process do |k|
      @imm = h.ARMExpandImm(k.imm12.to_boz(12)).to_i
    end
  end
  encoding :T1_reg
  encoding :T2_reg
  encoding :T3_reg
  encoding :A1_reg
  encoding :A1_rsr
end

instruction :DMB do # 8.8.43
  encoding :T1
  encoding :A1 do
    attrs :option
    bits '1111010101111111111100000101oooo', 'o' => :option
    format value: '#{@option == :sy ? "" : "#{@option}" }'
    process do |k|
      @option = {
        0b1111 => :sy,  0b1110 => :st,    0b1011 => :ish, 0b1010 => :ishst,
        0b0111 => :nsh, 0b0110 => :nshst, 0b0011 => :osh, 0b0010 => :oshst,
      }[k.option]
    end
  end
end

instruction :MOV do # 8.8.102-105
  encoding :T1_imm
  encoding :T2_imm
  encoding :T3_imm
  encoding :A1_imm do
    attrs :cond, :Rd, :imm, :setflags
    bits 'CCCC0011101S0000ddddiiiiiiiiiiii', 'i' => :imm12
    format value: '#{@Rd}, ##{@imm}'
    process do |k|
      raise NotThisInstructionError if k.Rd == 0b1111 && k.setflags == 1 # SUBS PC, LR
      (@imm, @carry) = h.ARMExpandImm_C(k.imm12.to_boz(12), 0) # TODO: APSR.C ?
      @imm = @imm.to_i
    end
  end
  encoding :A2_imm do
    attrs :cond, :Rd, :imm
    bits 'CCCC00110000jjjjddddiiiiiiiiiiii', 'i' => :imm12, 'j' => :imm4
    format operator: 'MOVW#{h.cond_to_s(@cond)}',
           value:    '#{@Rd}, ##{@imm}'
    process do |k|
      @imm = h.ZeroExtend(k.imm4.to_boz(4).concat(k.imm12.to_boz(12)), 32).to_i
      raise UnpredictableError if k.Rd == 15
    end
  end
  encoding :T1_reg
  encoding :T2_reg
  encoding :T3_reg
  encoding :A1_reg do
    attrs :cond, :Rd, :Rm, :setflags
    bits 'CCCC0001101S0000dddd00000000mmmm'
    format value: '#{@Rd}, #{@Rm}'
    process do |k|
      raise Indis::ARM::NotThisInstructionError if k.Rd == 0b1111 && k.setflags == 1
    end
  end
end

instruction :MOVT do # 8.8.106
  encoding :T1
  encoding :A1 do
    attrs :cond, :Rd, :imm
    bits 'CCCC00110100jjjjddddiiiiiiiiiiii', 'i' => :imm12, 'j' => :imm4
    format value: '#{@Rd}, ##{@imm}'
    process do |k|
      @imm = k.imm4.to_boz(4).concat(k.imm12.to_boz(12)).to_i
      raise UnpredictableError if k.Rd == 15
    end
  end
end

instruction :POP do # 8.8.131-132
  encoding :T1
  encoding :T2
  encoding :T3
  encoding :A1 do
    attrs :cond, :regs
    bits 'CCCC100010111101rrrrrrrrrrrrrrrr', 'r' => :regs_list
    format value: '{#{h.regs_to_s(@regs)}}'
    process do |k|
      @regs = h.regs_from_bits(k.regs_list)
      raise Indis::ARM::NotThisInstructionError if @regs.length < 2
      # XXX: UnalignedAllowed = FALSE;
      raise UnpredictableError if @regs.include?(:sp)
    end
  end
  encoding :A2
end

instruction :PUSH do # 8.8.133
  encoding :T1
  encoding :T2
  encoding :T3
  encoding :A1 do
    attrs :cond, :regs
    bits 'CCCC100100101101rrrrrrrrrrrrrrrr', 'r' => :regs_list
    format value: '{#{h.regs_to_s(@regs)}}'
    process do |k|
      @regs = h.regs_from_bits(k.regs_list)
      raise Indis::ARM::NotThisInstructionError if @regs.length < 2
    end
  end
  encoding :A2
end

instruction :SUB do # 8.8.221-226
  encoding :T1_imm
  encoding :T2_imm
  encoding :T3_imm
  encoding :T4_imm
  encoding :A1_imm
  encoding :T1_reg
  encoding :T2_reg
  encoding :A1_reg
  encoding :A1_rsr
  encoding :T1_spimm
  encoding :T2_spimm
  encoding :T3_spimm
  encoding :A1_spimm do
    attrs :cond, :Rd, :imm, :setflags
    bits 'CCCC0010010S1101ddddiiiiiiiiiiii', 'i' => :imm12
    format value: '#{@Rd}, sp, ##{@imm}'
    process do |k|
      raise Indis::ARM::NotThisInstructionError if k.Rd == 0b1111 && k.setflags == 1
      @imm = h.ARMExpandImm(k.imm12.to_boz(12)).to_i
    end
  end
  encoding :T1_spreg
  encoding :A1_spreg
end

instruction :STR do # 8.8.203-205
  encoding :T1_imm
  encoding :T2_imm
  encoding :T3_imm
  encoding :T4_imm
  encoding :A1_imm do
    attrs :cond, :Rn, :Rt, :imm, :add, :index, :wback
    bits 'CCCC010PU0W0nnnnttttiiiiiiiiiiii', 'P' => :p, 'U' => :u, 'W' => :w, 'i' => :imm12
    format value_offset:      '#{@Rt}, [#{@Rn}#{@imm != 0 ? ", ##{@imm}" : ""}]',
           value_preindexed:  '#{@Rt}, [#{@Rn}, ##{@imm}]!',
           value_postindexed: '#{@Rt}, [#{@Rn}], ##{@imm}'
    process do |k|
      raise Indis::ARM::NotThisInstructionError if k.p == 0 && k.w == 1 # STRT
      raise Indis::ARM::NotThisInstructionError if k.Rn == 0b1101 && k.p == 1 && k.u == 0 && k.w == 1 && k.imm12 == 0b100 # PUSH
      @index = k.p == 1
      @add = k.u == 1
      if @add
        @imm = k.imm12 # XXX: zero_expand(32)
      else
        @imm = -k.imm12 # XXX: zero_expand(32)
      end
      @wback = (k.p == 0 || k.w == 1)
      raise Indis::ARM::UnpredictableError if @wback && (k.Rn == 15 || k.Rn == k.Rt)
      
      if @index && !@wback
        @value_format = :value_offset
      elsif @index && @wback
        @value_format = :value_preindexed
      elsif !@index && @wback
        @value_format = :value_postindexed
      else
        raise "Unknown format combo"
      end
    end
  end
  encoding :T1_reg
  encoding :T2_reg
  encoding :A1_reg
end

instruction :LDR do # 8.8.62-66
  encoding :T1_imm
  encoding :T2_imm
  encoding :T3_imm
  encoding :T4_imm
  encoding :A1_imm do
    attrs :cond, :Rn, :Rt, :imm, :add, :index, :wback
    bits 'CCCC010PU0W1nnnnttttiiiiiiiiiiii', 'P' => :p, 'U' => :u, 'W' => :w, 'i' => :imm12
    format value_offset:      '#{@Rt}, [#{@Rn}#{@imm != 0 ? ", ##{@imm}" : ""}]',
           value_preindexed:  '#{@Rt}, [#{@Rn}, ##{@imm}]!',
           value_postindexed: '#{@Rt}, [#{@Rn}], ##{@imm}'
    process do |k|
      raise Indis::ARM::NotThisInstructionError if k.Rn == 0b1111 # LDR :A1_lit
      raise Indis::ARM::NotThisInstructionError if k.p == 0 && k.w == 1 # LDRT
      raise Indis::ARM::NotThisInstructionError if k.Rn == 0b1101 && k.p == 0 && k.u == 1 && k.w == 0 && k.imm12 == 0b100 # POP
      @index = k.p == 1
      @add = k.u == 1
      if @add
        @imm = k.imm12 # XXX: zero_expand(32)
      else
        @imm = -k.imm12 # XXX: zero_expand(32)
      end
      @wback = (k.p == 0 || k.w == 1)
      raise Indis::ARM::UnpredictableError if @wback && (k.Rn == k.Rt)
      
      if @index && !@wback
        @value_format = :value_offset
      elsif @index && @wback
        @value_format = :value_preindexed
      elsif !@index && @wback
        @value_format = :value_postindexed
      else
        raise "Unknown format combo"
      end
    end
  end
  encoding :T1_lit
  encoding :T2_lit
  encoding :A1_lit do
    attrs :cond, :Rn, :Rt, :imm, :add
    bits 'CCCC0101U0011111ttttiiiiiiiiiiii', 'U' => :u, 'i' => :imm12
    format value:       '#{@Rt}, [#{@Rn}, ##{@imm}]',
           value_const: '#{@Rt}, [#{@va+8+@imm}]',
           value_xref:  '#{@Rt}, =0x#{@xrefs[:value].value.to_s(16)}'
    process do |k|
      @Rn = :pc
      @add = k.u == 1
      if @add
        @imm = k.imm12 # XXX: zero_expand(32)
      else
        @imm = -k.imm12 # XXX: zero_expand(32)
      end
    end
  end
  encoding :T1_reg
  encoding :T2_reg
  encoding :A1_reg do
    attrs :cond, :Rn, :Rt, :Rm, :imm, :add, :index, :wback, :imm_shift
    bits 'CCCC011PU0W1nnnnttttiiiiiTT0mmmm', 'P' => :p, 'U' => :u, 'W' => :w, 'i' => :imm5, 'T' => :type
    format value_offset:      '#{@Rt}, [#{@Rn}, #{@Rm}#{@imm != 0 ? ", ##{@imm}" : ""}]',
           value_preindexed:  '#{@Rt}, [#{@Rn}, #{@Rm}#{@imm != 0 ? ", ##{@imm}" : ""}]!',
           value_postindexed: '#{@Rt}, [#{@Rn}], #{@Rm}#{@imm != 0 ? ", ##{@imm}" : ""}'
    process do |k|
      raise Indis::ARM::NotThisInstructionError if k.p == 0 && k.w == 1 # LDRT
      @index = k.p == 1
      @add = k.u == 1
      (@imm_shift, @imm) = h.DecodeImmShift(k.type.to_bo, k.imm5.to_bo)
      if @add
        @imm = @imm.to_i
      else
        @imm = -(@imm.to_i)
      end
      @wback = (k.p == 0 || k.w == 1)
      raise Indis::ARM::UnpredictableError if k.Rm == 15
      raise Indis::ARM::UnpredictableError if @wback && (k.Rn == k.Rt)
      # TODO: also raise on: if ArchVersion() < 6 && wback && m == n then UNPREDICTABLE
      
      if @index && !@wback
        @value_format = :value_offset
      elsif @index && @wback
        @value_format = :value_preindexed
      elsif !@index && @wback
        @value_format = :value_postindexed
      else
        raise "Unknown format combo"
      end
    end
  end
end