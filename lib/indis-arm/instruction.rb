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
require 'indis-core/entity'

module Indis
  module ARM
    
    # ARM::Instruction is a code {Indis::Entity entity} that represens an ARM
    # instruction
    class Instruction < Indis::Entity
      # Instructions can have different value formats. In such a case, +value_format+
      # specifies the format to use
      # @return [Symbol]
      attr_accessor :value_format
      
      # @param [Fixnum] vmaddr virtual address
      # @param [Fixnum] bytes bytes that represent an instruction
      def initialize(vmaddr, bytes)
        super vmaddr
        @size = 4
        m = self.class.kmap(bytes)
        self.class.process_automap.each { |p| self.instance_exec(m, &p) } if self.class.process_automap
        self.instance_exec(m, &self.class.process_block) if self.class.process_block
      end
      
      # @return [Indis::ARM::InstructionHelper] helper that provides common methods for DSL
      def h
        InstructionHelper
      end
      
      def to_s
        s = self.instance_eval "\"#{self.class.formats[:operator]}\""
        if @value_format
          fmt = self.class.formats[@value_format]
          v = self.instance_eval "\"#{fmt}\""
        else
          v = self.instance_eval "\"#{self.class.formats[:value]}\"" if self.class.formats[:value]
        end
        s = "#{s}\t#{v}" if v
        s
      end
      
      def to_a
        s = self.instance_eval "\"#{self.class.formats[:operator]}\""
        if @value_format
          fmt = self.class.formats[@value_format]
          v = self.instance_eval "\"#{fmt}\""
        else
          v = self.instance_eval "\"#{self.class.formats[:value]}\"" if self.class.formats[:value]
        end
        [s, v]
      end
      
      class << self
        attr_reader :name # @return [String] instruction name
        
        attr_reader :encoding # @return [String] instruction encoding per ARMARM
        
        attr_reader :process_block # @return [Proc] data-processing proc
        
        attr_reader :formats # @return [Hash] output formats
        
        attr_reader :process_automap # @return [Array] a list of automapping procs
        
        # @return [String] instruction mask bits
        def bits_mask
          @bits_mask ||= @bits.gsub('0', '1').gsub(/[^1]/, '0').to_i(2)
        end
        
        # @return [String] instruction matching bits
        def bits_match
          @bits_match ||= @bits.gsub(/[^01]/, '0').to_i(2)
        end
        
        # @return [OpenStruct] a map of known fields to instruction value
        def kmap(v)
          return OpenStruct.new unless @kmap
          
          map = @kmap.inject({}) do |map, (m, o, n)|
            map[n] = (v & m) >> o
            map
          end
          OpenStruct.new(map)
        end
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