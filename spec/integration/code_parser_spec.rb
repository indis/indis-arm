require 'indis-core/target'
require 'indis-macho'
require 'indis-arm/code_parser'

describe Indis::ARM::CodeParser do
  it "should decode arm instructions in given section" do
    pending
    t = Indis::Target.new('spec/fixtures/single-object.o')
    t.load
    
    section = t.segments.find { |seg| seg.name == '__TEXT' }.sections.find { |sect| sect.name == '__text' }
    
    code_parser = Indis::ARM::CodeParser.new(t)
    
    code_parser.reparse_section(section)
    
    sm = t.vmmap[section.to_vmrange]
    
    sm.each_with_index do |b, idx|
      break if idx >= section.vmsize

      if idx % 4 == 0
        b.should be_a(Indis::Entity)
        b.should be_a(Indis::ARM::Instruction)
      else
        b.should be_nil
      end
    end
  end
  
  it "should parse known instructions" do
    pending
    code_parser = Indis::ARM::CodeParser.new(double("Target", vmmap: double("VMMap")))
    
    i = code_parser.instance_eval { build_instruction(0, 0xe92d4080) }
    i.should_not be_a(Indis::ARM::UnknownInstruction)
  end
  
  it "should load instructions" do
    pending
    Indis::ARM::CodeParser.load_instructions
    expect { Indis::ARM.const_get('PUSHInstruction_A1') }.not_to raise_error
  end
  
  it "should honor NotThisInstructionError" do
    pending
    code_parser = Indis::ARM::CodeParser.new(double("Target", vmmap: double("VMMap")))
    
    i = code_parser.instance_eval { build_instruction(0, 0xe59f0024) }
    i.class.should == Indis::ARM::LDRInstruction_A1_lit
  end
end