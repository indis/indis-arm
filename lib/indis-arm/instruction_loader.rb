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
require 'indis-arm/instruction'

module Indis
  module ARM
    
    class NotThisInstructionError < RuntimeError; end
    class UnpredictableError < RuntimeError; end
    
    # InstructionLoader is a DSL parser for arm7.inst.rb DSL.
    # The DSL is evaluated in the context of InstructionLoader singleton, the
    # only top-level command is {Indis::ARM::InstructionLoader#instruction}
    class InstructionLoader
      include Singleton
      
      # Loads and processes the DSL
      # @return [Array] all mapped classes from DSL
      def load
        return @classes if @classes
        
        @classes = []
        instr_file = File.join(File.dirname(__FILE__), 'arm7.inst.rb')
        self.instance_eval open(instr_file).read, instr_file, 1
        
        @classes
      end
      
      # Loads a named instruction. The block is evaluated in a context of
      # newly-created {Indis::ARM::EncodingLoader}.
      # @param [Symbol] name instruction name
      def instruction(name, &block)
        el = EncodingLoader.new(name, @classes)
        el.instance_eval(&block)
      end
    end
    
    class EncodingLoader
      def initialize(name, arr)
        @name = name
        @classes = arr
      end
      
      # Loads a specific instruction encoding. The block is evaluated in a
      # context of newly-created {Indis::ARM::MnemonicLoader}.
      # @param [Symbol] enc instruction encoding name
      def encoding(enc, &block)
        unless block_given?
          #puts "Encoding #{enc} of #{@name} is undefined yet"
          return
        end
        
        name = @name
        klass = Class.new(Indis::ARM::Instruction) { @name = name; @encoding = enc }
        ARM.const_set("#{name}Instruction_#{enc}", klass)
        
        ml = MnemonicLoader.new(klass)
        ml.instance_eval(&block)
        
        @classes << klass
      end
    end
    
    class MnemonicLoader
      # A default map. Would set up the mapping only if the attribute name
      # was passed in {Indis::ARM::MnemonicLoader#attrs}
      AUTOMAPPED = {
        'C' => :cond,
        'n' => :Rn,
        'm' => :Rm,
        'd' => :Rd,
        't' => :Rt,
        'S' => :setflags,
      }
      
      AUTOMAPPED_PROCS = {
        cond: proc { |k| @cond = h.cond(k.cond) },
        Rn: proc { |k| @Rn = h.reg(k.Rn) },
        Rm: proc { |k| @Rm = h.reg(k.Rm) },
        Rd: proc { |k| @Rd = h.reg(k.Rd) },
        Rt: proc { |k| @Rt = h.reg(k.Rt) },
        setflags: proc { |k| @setflags = k.setflags == 1 },
      }
      
      def initialize(klass)
        @klass = klass
      end
      
      # Loads bit representation of instruction
      # @overload bits(bitstring)
      #   @param [String] bitstring a string with no special-mapped bits (either no specail bits at all, or all bits are automapped)
      # @overload bits(bitstring, map)
      #   @param [String] bitstring a string with bits map
      #   @param [Hash{String => Symbol}] map a map from bit string to parsed symbol
      def bits(*args)
        raise "Malformed bits field" if args.length < 1 || args.length > 2
        b = args.first
        @klass.instance_eval { @bits = b }
        
        map = {}
        AUTOMAPPED.each { |k,v| map[k] = v if @klass_attrs.include?(v) }
        map.merge!(args[1]) if args.length == 2
        
        a = map.map do |v, name|
          # TODO: chek on what happens if there is no cond 'C'
          mask = b.gsub(Regexp.new("[^#{v}]"), '0').gsub(/[^0]/, "1")
          ofs = mask.match(/0*$/)[0].length
          mask = mask.to_i(2)
          
          [mask, ofs, name]
        end
        
        @klass.instance_eval { @kmap = a }
      end
      
      # Loads instruction attributes
      def attrs(*attrs)
        @klass_attrs = attrs
        @klass.instance_eval { attr_reader *attrs }
      end
      
      # Loads instruction format
      def format(fmt)
        if @klass_attrs.include?(:setflags)
          formats = { operator: '#{self.class.name}#{h.flag @setflags, "S"}#{h.cond_to_s(@cond)}' }
        else
          formats = { operator: '#{self.class.name}#{h.cond_to_s(@cond)}' }
        end
        formats.merge!(fmt)
        @klass.instance_eval { @formats = formats }
      end
      
      # Loads instruction processing block
      def process(&block)
        automap_keys = @klass_attrs & AUTOMAPPED.values
        automap_proc = AUTOMAPPED_PROCS.map { |k,p| automap_keys.include?(k) ? p : nil }.compact
        @klass.instance_eval { @process_automap = automap_proc }
        @klass.instance_eval { @process_block = block }
      end
    end
    
  end
end