require 'indis-arm/ual_loader'

describe Indis::ARM::UalLoader do
  it "should load instructions" do
    Indis::ARM::UalLoader.instance.namespaces.length.should > 0
    Indis::ARM::UalLoader.instance.commons.length.should > 0
  end
  
  context "thumb-1 parser" do
    fixtures = open('spec/fixtures/matcher-spec-gen.disasm').readlines.map { |l| l.strip.split("\t", 3) }
    
    fixtures.each do |(adr, val, opc)|
      opc.gsub!("\t", " ")
      it "parses 0x#{val.strip} as \"#{opc}\"" do
        i = Indis::ARM::UalLoader.instance.map_instruction(Indis::ARM::Instruction.new(2, 0), val.to_i(16), :thumb16)
        i.should decode_to_opcode(opc)
      end
    end
    
    special_cases = {
      0b0000000000100010 => 'movs r2, r4',
      
      0b0000100000001010 => 'lsrs r2, r1, #0',
      0b0000100001001010 => 'lsrs r2, r1, #1',
      
      0b0001000000000001 => 'asrs r1, r0, #0',
      
      0b0100001001100110 => 'rsbs r6, r4, #0',
      0b0100001001111001 => 'rsbs r1, r7, #0',
      
      0x4373 => 'muls r3, r6, r3',
      0x4342 => 'muls r2, r0, r2',
      
      0x4b01 => 'ldr r3, [pc, #4]',
      
      # TODO: adr
      
      0xb07f => 'add sp, sp, #508',
      0xb099 => 'sub sp, sp, #100',
      
      0xbef2 => 'bkpt 0xf2',
      
      0xc038 => 'stm r0!, {r3, r4, r5}',
      
      0xc93e => 'ldm r1, {r1, r2, r3, r4, r5}',
      0xcbf0 => 'ldm r3!, {r4, r5, r6, r7}',
    }
    
    special_cases.each do |val, opc|
      it "parses 0x#{val.to_s 16} as \"#{opc}\"" do
        i = Indis::ARM::UalLoader.instance.map_instruction(Indis::ARM::Instruction.new(2, 0), val, :thumb16)
        i.should decode_to_opcode(opc)
      end
    end
  end
  
  context "thumb-2 parser" do
    fixtures = open('spec/fixtures/matcher-thumb2-is.disasm').readlines.map { |l| l.strip.split("\t", 3) }
    
    fixtures.each do |(adr, val, opc)|
      opc.gsub!("\t", " ")
      it "parses 0x#{val.strip} as \"#{opc}\"" do
        i = Indis::ARM::UalLoader.instance.map_instruction(Indis::ARM::Instruction.new(4, 0), val.to_i(16), :thumb32)
        i.should decode_to_opcode(opc)
      end
    end
    
    special_cases = {
      0xe80dc001 => 'srsdb sp, fiq',
      0xe82dc002 => 'srsdb sp!, irq',
      
      0xe88107fc => 'stm.w r1, {r2, r3, r4, r5, r6, r7, r8, r9, sl}',
      0xe8a20038 => 'stm.w r2!, {r3, r4, r5}',
      
      0xe8930007 => 'ldm.w r3, {r0, r1, r2}',
      0xe8b41fe0 => 'ldm.w r4!, {r5, r6, r7, r8, r9, sl, fp, ip}',
      
      0xe8bd07fe => 'pop.w {r1, r2, r3, r4, r5, r6, r7, r8, r9, sl}',
      
      0xe92d03f8 => 'push.w {r3, r4, r5, r6, r7, r8, r9}',
    }
    
    special_cases.each do |val, opc|
      it "parses 0x#{val.to_s 16} as \"#{opc}\"" do
        i = Indis::ARM::UalLoader.instance.map_instruction(Indis::ARM::Instruction.new(4, 0), val, :thumb32)
        i.should decode_to_opcode(opc)
      end
    end
    
  end
end
