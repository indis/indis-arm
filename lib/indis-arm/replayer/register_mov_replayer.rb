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
      
    class RegisterMovReplayer
      def replay(instr, cpustate)
        case instr.class.name
        when :MOV
          if instr.respond_to?(:imm)
            cpustate.write_to(instr.Rd, instr.imm)
          else
            cpustate.write_to(instr.Rd, cpustate.read(instr.Rm))
          end
        when :MOVT
          val = (cpustate.read(instr.Rd) & 0xffff) + ((instr.imm & 0xffff) << 16)
          cpustate.write_to(instr.Rd, val)
        end
      end
    end
    
  end
end