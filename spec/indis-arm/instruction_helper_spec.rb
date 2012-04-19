require 'indis-arm/instruction_helper'

describe Indis::ARM::InstructionHelper do
  it "should decode registers" do
    b = '0000111100000010'.reverse.to_i(2)
    r = Indis::ARM::InstructionHelper.regs_from_bits(b)
    r.should == [:r4, :r5, :r6, :r7, :lr]
  end
end

describe Indis::ARM::PseudoCodeInstructionHelper do
  it "should perform ZeroExtend" do
    Indis::ARM::InstructionHelper.ZeroExtend('1101'.to_bo, 6).to_s.should == '001101'
  end
  
  it "should perform LSR" do
    a = Indis::ARM::InstructionHelper.LSR_C('101100'.to_bo, 3)
    a[0].to_s.should == '000101'
    a[1].should == 1
  end
  
  it "should perform Shift_C" do
    Indis::ARM::InstructionHelper.Shift_C('101100'.to_bo, :SRType_ROR, 2, 0).map{|v|v.to_s}.should == ['001011', '1']
  end
  
  it "should perform ARMExpandImm_C" do
    Indis::ARM::InstructionHelper.ARMExpandImm('000000001100'.to_bo).to_i.should == 12
  end
end
