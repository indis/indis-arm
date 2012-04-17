require 'indis-arm/instruction_loader'

describe Indis::ARM::InstructionLoader do
  before(:all) { Indis::ARM::InstructionLoader.instance.load }
  
  it "should load instructions" do
    expect { Indis::ARM.const_get('PUSHInstruction_A1') }.not_to raise_error
  end
  
  it "should parse bitmap to mask and match" do
    Indis::ARM::PUSHInstruction_A1.bits_mask.should == 0xfff0000
    Indis::ARM::PUSHInstruction_A1.bits_match.should == 0x92d0000
  end
  
  it "should create attr_readers for fields" do
    i = Indis::ARM::PUSHInstruction_A1.new(0, 0xe92d4080)
    expect { i.regs }.not_to raise_error(NoMethodError)
  end
  
  it "should make a keymap for passed values" do
    m = Indis::ARM::PUSHInstruction_A1.kmap(0xe92d4080)
    m.cond.should == 0xe
    m.regs_list.should == 0x4080
  end
  
  it "should eval process block and set ivars" do
    i = Indis::ARM::PUSHInstruction_A1.new(0, 0xe92d4080)
    i.regs.should == [:r7, :r14]
  end
  
  it "should set instruction name" do
    Indis::ARM::PUSHInstruction_A1.name.should == :PUSH
  end
  
  it "should set instruction encoding" do
    Indis::ARM::PUSHInstruction_A1.encoding.should == :A1
  end
  
  it "should raise NotThisInstructionError if the other mnemonic should be searched for" do
    expect { Indis::ARM::LDRInstruction_A1_imm.new(0, 0xe59f0024) }.to raise_error(Indis::ARM::NotThisInstructionError)
  end
  
  it "should provide full mnemonic when asked to_s" do
    Indis::ARM::PUSHInstruction_A1.new(0, 0xe92d4080).to_s.should == "PUSH\t{r7, lr}"
    Indis::ARM::MOVInstruction_A1_reg.new(0, 0xe1a0700d).to_s.should == "MOV\tr7, sp"
    Indis::ARM::SUBInstruction_A1_spimm.new(0, 0xe24dd00c).to_s.should == "SUB\tsp, sp, #12"
    Indis::ARM::STRInstruction_A1_imm.new(0, 0xe5070004).to_s.should == "STR\tr0, [r7, #-4]"
    Indis::ARM::STRInstruction_A1_imm.new(0, 0xe58d1004).to_s.should == "STR\tr1, [sp, #4]"
    Indis::ARM::LDRInstruction_A1_imm.new(0, 0xe5171004).to_s.should == "LDR\tr1, [r7, #-4]"
    Indis::ARM::LDRInstruction_A1_imm.new(0, 0xe59d2004).to_s.should == "LDR\tr2, [sp, #4]"
    Indis::ARM::LDRInstruction_A1_lit.new(0, 0xe59f0024).to_s.should == "LDR\tr0, [pc, #36]"
    Indis::ARM::LDRInstruction_A1_reg.new(0, 0xe79f1001).to_s.should == "LDR\tr1, [pc, r1]"
    Indis::ARM::ADDInstruction_A1_imm.new(0, 0xe2804001).to_s.should == "ADD\tr4, r0, #1"
  end
  
  it "should provide cond when there is 'C' in bits" do
    i = Indis::ARM::PUSHInstruction_A1.new(0, 0xe92d4080)
    i.cond.should == :al
  end
  
  it "should not provide cond when there is no 'C' in bits" do
    i = Indis::ARM::DMBInstruction_A1.new(0, 0xf57ff05f)
    expect { i.cond }.to raise_error(NoMethodError)
  end
  
  it "should provide Rx when there are 'n', 'd', 'm' in bits" do
    i = Indis::ARM::MOVInstruction_A1_reg.new(0, 0xe1a0700d)
    i.Rd.should == :r7
    i.Rm.should == :sp
  end
  
  it "should not provide Rx when there are no 'n', 'd', 'm' in bits" do
    i = Indis::ARM::MOVInstruction_A1_reg.new(0, 0xe1a0700d)
    expect { i.Rn }.to raise_error(NoMethodError)
  end
end
