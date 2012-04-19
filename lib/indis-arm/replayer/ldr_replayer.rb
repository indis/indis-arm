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

module Indis
  module ARM
    
    class LdrReplayer
      def initialize(target)
        @target = target
      end
      
      def replay(instr, cpustate)
        return unless instr.class.name == :LDR
        case instr.class.encoding
        when :A1_reg
          if instr.index && !instr.wback
            ofs = cpustate.read(instr.Rn)+cpustate.read(instr.Rm)+instr.imm
            datab = Indis::DataEntity.new(ofs, 4, @target.vmmap)
            @target.vmmap.map!(datab)
            cpustate.write_to(instr.Rt, datab.value)
            return "load from #{ofs}"
          else
            raise "bad ldr #{instr}"
          end
        else
          raise "bad ldr #{instr}"
        end
      end
    end
    
  end
end