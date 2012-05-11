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

require 'indis-arm/instruction'
require 'indis-arm/ual_loader'

module Indis
  module ARM
    
    class ThumbResolver
      def initialize
        @it_conditions = []
      end
      
      def resolve(io, vmbase)
        loader = UalLoader.instance
        
        # read the initial 2 bytes
        bytes = io.read(2).unpack('v')[0]
        begin
          opcode = bytes >> 11
          if opcode == 0b11101 || opcode == 0b11110 || opcode == 0b11111
            # if it's Thumb2, read the trailing 2 bytes to 4 total
            bytes = (bytes << 16) + io.read(2).unpack('v')[0]
            instr_size = 4
            root_matcher = :thumb32
          else
            instr_size = 2
            root_matcher = :thumb16
          end
          
          # create a new instruction
          instr = Instruction.new(instr_size, vmbase)
          
          # map IT conditions if applicable
          if @it_conditions.length > 0
            instr.it_mnemonic = @it_conditions.shift
            instr.in_it = true
            instr.last_in_it = @it_conditions.length == 0
          end
          
          # map traits
          loader.map_instruction(instr, bytes, root_matcher)
          
          # process IT instruction
          @it_conditions = instr.values[:conditions] if instr.traits.include?(:it)
          
          # yield to outer world
          yield instr
          
          vmbase += instr_size
          
          bytes = io.read(2)
          bytes = bytes.unpack('v')[0] if bytes
        end while bytes
      end
    end
    
  end
end
