##############################################################################
#   Indis framework                                                          #
#   Copyright (C) 2012 Vladimir "Farcaller" Pouzanov <farcaller@gmail.com>   #
#                                                                            #
#   This program is free software: you can redistribute it and/or modify     #
#   it under the terms of the GNU General Public License as published by     #
#   the Free Software Foundation, either version 3 of the License, or        #
#   (at your option) any later version.                                      #
#                                                                            #
#   This program is distributed in the hope that it will be useful,          #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#   GNU General Public License for more details.                             #
#                                                                            #
#   You should have received a copy of the GNU General Public License        #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.    #
##############################################################################

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