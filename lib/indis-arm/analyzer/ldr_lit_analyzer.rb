require 'indis-core/data_entity'

module Indis
  module ARM
    module Analyzer
      
      class LDRLitAnalyzer < Analyzer
        
        def initialize(target)
          super target, :instruction_mapped
        end
        
        def instruction_mapped(instr)
          return unless instr.class.name == :LDR && instr.class.encoding == :A1_lit
          
          datab = Indis::DataEntity.new(instr.vmaddr+instr.imm+8, 4, @target.vmmap)
          @target.vmmap.map!(datab)
          instr.tags[:value] = datab
          datab.tags[:loaded_by] = instr
        end
      end
      
    end
  end
end