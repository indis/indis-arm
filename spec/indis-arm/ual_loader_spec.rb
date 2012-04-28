require 'indis-arm/ual_loader'

describe Indis::ARM::UalLoader do
  it "should load instructions" do
    Indis::ARM::UalLoader.instance.matchers.length.should == 40
    Indis::ARM::UalLoader.instance.commons.length.should == 19
  end
  
  context "thumb parser" do
    fixtures = open('spec/fixtures/matcher-spec-gen.txt').readlines.map { |l| l.strip.split("\t", 3) }
    
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
      
      
      
      0xe7fa => 'b -12',
    }
    
    special_cases.each do |val, opc|
      it "parses 0x#{val.to_s 16} as \"#{opc}\"" do
        i = Indis::ARM::UalLoader.instance.map_instruction(Indis::ARM::Instruction.new(2, 0), val, :thumb16)
        i.should decode_to_opcode(opc)
      end
    end
  end
end
