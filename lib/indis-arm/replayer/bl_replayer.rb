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

require 'indis-core/cstring_entity'

module Indis
  module ARM
      
    class BlReplayer
      def initialize(target)
        @target = target
      end
      
      def replay(instr, cpustate)
        return unless instr.class.name == :BL
        sym = instr.tags[:branch_to_sym]
        sym_name = sym ? sym.name : instr.branch_address
        
        if sym_name == '_objc_msgSend'
          s = @target.resolve_symbol_at_address(cpustate.r0)
          cpustate.r0 = s.name if s
          CStringEntity.new(cpustate.r1, @target.vmmap)
          cpustate.r1 = "@selector(#{CStringEntity.new(cpustate.r1, @target.vmmap).value})"
        end
        
        sa = []
        [:r0, :r1, :r2, :r3].each do |r|
          val = cpustate.read(r)
          break if val == :junk
          sa << val
        end
        s = "#{sym_name}(#{sa.join(', ')})"
        
        cpustate.r0 = "#{instr.vmaddr}_ret1"
        cpustate.r1 = :junk #"#{instr.vmaddr}_ret2"
        cpustate.r2 = :junk #"#{instr.vmaddr}_ret3"
        cpustate.r3 = :junk #"#{instr.vmaddr}_ret4"
        s
      end
    end
    
  end
end