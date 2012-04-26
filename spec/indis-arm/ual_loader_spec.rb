require 'indis-arm/ual_loader'

describe Indis::ARM::UalLoader do
  it "should load instructions" do
    Indis::ARM::UalLoader.instance.matchers.length.should == 31
    Indis::ARM::UalLoader.instance.commons.length.should == 16
  end
  
  context "thumb parser" do
    fixtures = open('spec/fixtures/matcher-spec-gen.txt').readlines.map { |l| l.strip.split("\t", 3) }
    
    fixtures.each do |(adr, val, opc)|
      opc.gsub!("\t", " ")
      it "parses 0x#{val.strip} as \"#{opc}\"" do
        i = Indis::ARM::UalLoader.instance.map_instruction(val.to_i(16), :thumb)
        i.to_s.should == opc
      end
    end
  end
end
