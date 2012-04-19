require 'indis-core/target'
require 'indis-macho'
require 'indis-arm/arm_architecture'

describe Indis::BinaryArchitecture::ArmArchitecture do
  it "should be auto-resolved for arm binary" do
    t = Indis::Target.new('spec/fixtures/single-object.o')
    t.load
    
    t.architecture.should be_a(Indis::BinaryArchitecture::ArmArchitecture)
  end
end