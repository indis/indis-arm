module Indis
  module ARM
    module Analyzer
      
      class BLAnalyzer < Analyzer
        
        def initialize(target)
          super target, :instruction_mapped
        end
        
        def instruction_mapped(instr)
          return unless instr.class.name == :BL
          sym = @target.resolve_symbol_at_address(instr.branch_address)
          instr.tags[:branch_to_sym] = sym if sym
        end
      end
      
    end
  end
end