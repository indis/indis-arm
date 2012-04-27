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

require 'ostruct'
require 'indis-arm/instruction_helper'
require 'indis-arm/instruction/thumb_it'
require 'indis-arm/instruction/format_helper'
require 'indis-core/entity'

module Indis
  module ARM
    
    # ARM::Instruction is a code {Indis::Entity entity} that represens an ARM
    # instruction
    class Instruction < Indis::Entity
      include ThumbIt
      include FormatHelper
      
      attr_reader :traits
      attr_accessor :size, :mnemonic, :values, :operands, :sets_flags

      def initialize(size, ofs)
        super(ofs)
        @size = size
        @mnemonic = ''
        @values = {}
        @operands = ''
        @it_mnemonic = ''
        @in_it = false
        @traits = []
      end

      def operands_subst
        o = @operands.dup
        while o.index('{')
          o.gsub!(/{{[^}]+}}/) do |mstr|
            if mstr[2] == 'r'
              register_to_s(self.values[mstr[2...-2].to_sym])
            else
              self.values[mstr[2...-2].to_sym]
            end
          end
        end
        o
      end

      def to_s
        "#{@mnemonic} #{operands_subst}"
      end
    end
    
    # UnknownInstruction represents an unknown (not yet mapped in DSL) instruction
    class UnknownInstruction < Instruction
      def initialize(vmaddr, bytes)
        super
        @val = bytes
      end
      
      def to_s
        "UNK\t#{@val.to_s(16).upcase}"
      end
      
      def to_a
        ['UNK', @val.to_s(16).upcase]
      end
    end
  end
end