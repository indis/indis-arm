require 'indis-core'
require 'indis-macho'
require 'indis-arm'
require 'indis-arm/code_parser'
require 'indis-arm/function_builder'

describe Indis::ARM::FunctionBuilder do
  it "should build function graph" do
    t = Indis::Target.new('spec/fixtures/app-arm-release.o').load
    
    Indis::ARM::Analyzer::BLAnalyzer.new(t)
    Indis::ARM::Analyzer::LDRLitAnalyzer.new(t)
    
    sym = t.symbols.find { |sym| sym.name == '_main' }
    
    code_parser = Indis::ARM::CodeParser.new(t)
    code_parser.reparse_section(sym.section)
    
    fb = Indis::ARM::FunctionBuilder.new(t, sym)
    fb.process
  end
end