require 'indis-arm/instruction_resolver/thumb_resolver'

describe Indis::ARM::ThumbResolver do
  it "resolves IT blocks" do
    fixtures = open('spec/fixtures/matcher-spec-it-gen.txt').readlines.map { |l| l.strip.split("\t", 3) }
    text = fixtures.map { |(adr, val, opc)| opc.gsub("\t", ' ') }.join("\n")
    bin = fixtures.map { |(adr, val, opc)| [val.strip.to_i(16)].pack('v*') }.join('')
    
    tr = Indis::ARM::ThumbResolver.new
    
    s = ''
    tr.resolve(StringIO.new(bin), 0) { |instr| s += instr.to_s + "\n" }
    s.strip.should == text.strip
  end
end
