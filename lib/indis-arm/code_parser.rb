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
require 'indis-arm/instruction'
require 'indis-arm/instruction_loader'

module Indis
  module ARM
  
    class CodeParser
      attr_accessor :endianness
      
      def initialize(target)
        @target = target
        @map = target.vmmap
        
        @endianness = :little
        @state = CpuState.new
      end
      
      def reparse_section(sect)
        virt_addr = sect.vmaddr
        io = StringIO.new(sect.bytes)
        
        while virt_addr < sect.vmaddr + sect.vmsize
          @state.pc = virt_addr + 8 # XXX: 4 for thumb
          
          bytes = io.read(4)
          i = build_instruction(virt_addr, bytes.unpack('V')[0])
          @map.map(i)
          @target.publish_event(:instruction_mapped, i)
          
          if i.size == 2
            io.ungetbyte(bytes[2..-1])
            virt_addr += 2
          else
            virt_addr += 4
          end
        end
      end
      
      def endianness=(en)
        raise "Unknown endianness set" unless en == :big || en == :little
        @endianness = en
      end
      
      private
      def build_instruction(va, bytes)
        CodeParser.instruction_masks.each do |m, arr|
          instr = arr.find { |i| (bytes & m) == i.bits_match}
          begin
            return instr.new(va, bytes) if instr
          rescue NotThisInstructionError
            next
          end
        end
        UnknownInstruction.new(va, bytes)
      end
      
      class << self
        def instruction_masks
          @instruction_masks = load_instructions unless @instruction_masks

          @instruction_masks
        end
        
        def load_instructions
          masks = {}
          
          InstructionLoader.instance.load.each do |klass|
            m = klass.bits_mask
            a = masks[m]
            unless a
              a = []
              masks[m] = a
            end
            
            a << klass
          end
          
          masks
        end
      end
    end
    
  end
end
