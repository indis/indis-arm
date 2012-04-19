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

require 'indis-arm/cpu_state'
require 'indis-arm/replayer/register_modification_replayer'
require 'indis-arm/replayer/register_mov_replayer'
require 'indis-arm/replayer/bl_replayer'
require 'indis-arm/replayer/ldr_replayer'

module Indis
  module ARM
    
    class PCModifiedError < RuntimeError; end
    
    class FunctionBuilder
      PC_STEP = 8 # no thumb for you
      
      def initialize(target, symbol)
        @target = target
        @symbol = symbol
        @cpustate = CpuState.new
        @cpustate.pc = symbol.vmaddr + PC_STEP
        @cpustate.r0 = :arg1
        @cpustate.r1 = :arg2
        @cpustate.r2 = :arg3
        @cpustate.r3 = :arg4
        
        @pc_replayer = RegisterModificationReplayer.new(:pc)
        @common_replayers = [RegisterMovReplayer.new, BlReplayer.new(target), LdrReplayer.new(target)]
      end
      
      def process
        while true
          process_current_instruction
          @cpustate.pc += 4
        end
      end
      
      private
      def process_current_instruction
        instr = @target.vmmap[@cpustate.pc-PC_STEP]
        return unless instr
        raise RuntimeError, "Bad kind of block #{instr.class}: #{instr}" unless instr.kind_of?(Instruction)
        
        comments = @common_replayers.map { |r| r.replay(instr, @cpustate) }.compact
        comments_s = comments.compact.join(', ')
        
        puts "#{sprintf("%8d", instr.vmaddr)} #{instr}#{comments.length ? '    ; '+comments_s : ''}"
        
        #puts @cpustate
        
        # drop away if we got onto something that breaks pc
        raise PCModifiedError if @pc_replayer.replay(instr, @cpustate)
      end
    end
    
  end
end