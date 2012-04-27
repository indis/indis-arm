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

require 'singleton'
require 'indis-core/binaryops_string'
require 'indis-arm/instruction'

module Indis
  module ARM
    
    class BadMatchError < RuntimeError; end
    
    class UalLoader
      include Singleton
      
      attr_reader :matchers, :commons
      
      def initialize
        load_ual
      end
      
      def map_instruction(bytes, root)
        instr = Instruction.new
        match(root, instr, bytes)
        instr
      end
      
      private
      def match(name, instr, bytes)
        instr.traits << name
        matcher = @matchers[name]
        instance_exec(instr, bytes, &matcher.proc)
      end
      
      def common(*args)
        cname = args.shift
        args[0].traits << cname
        instance_exec(*args, &@commons[cname])
      end
      
      def load_ual
        instr_file = File.join(File.dirname(__FILE__), 'ual.inst.rb')
        dsl = UalTopLevelDSL.new
        dsl.instance_eval open(instr_file).read, instr_file, 1
        @matchers = dsl.matchers
        @commons = dsl.commons
      end
      
      def h
        @instructions_helper ||= UalInstructionsHelper.new
      end
    end
    
    class UalInstructionsHelper
      def ZeroExtend(bits_x, i)
        bits_x.to_bo.zero_extend(i).to_i
      end
      
      def DecodeImmShift(bits2_type, bits5_imm5)
        imm = bits5_imm5.to_i
        case bits2_type.to_i
        when 0b00
          [:lsl, imm]
        when 0b01
          [:lsr, imm == 0 ? 32 : imm]
        when 0b10
          [:asr, imm == 0 ? 32 : imm]
        when 0b11
          imm == 0 ? [:rrx, 1] : [:ror, imm]
        end    
      end
    end
    
    class Matcher
      attr_reader :name, :proc
      def initialize(name, p)
        @name = name
        @proc = p
      end
    end
    
    class UalTopLevelDSL
      attr_reader :matchers, :commons
      
      def initialize
        @matchers = {}
        @commons = {}
      end
      
      def matcher(args, &block)
        if args.is_a?(Hash)
          from = args.keys.first
          to = args[from]
          raise RuntimeError, "No parent matcher #{from} for matcher #{to}" unless @matchers[from]
        else
          to = args
        end
        
        raise RuntimeError, "Matcher #{to} is already defined" if @matchers[to]
        
        @matchers[to] = Matcher.new(to, block)
      end
      
      def common(name, &block)
        raise RuntimeError, "Common block #{name} is already defined" if @commons[name]
        
        @commons[name] = block
      end
    end
    
  end
end
