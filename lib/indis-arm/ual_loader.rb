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
require 'indis-core/binaryops_fixnum'
require 'indis-arm/instruction'
require 'indis-arm/instruction_helper'

module Indis
  module ARM
    
    class BadMatchError < RuntimeError; end
    class UnpredictableError < RuntimeError; end
    
    class UalLoader
      include Singleton
      
      attr_reader :namespaces, :commons
      
      def initialize
        load_ual
      end
      
      def map_instruction(instr, bytes, root)
        instr.namespace = root
        match(root, instr, bytes)
        if instr.lazy
          instr.lazy.each { |args| common(*args) }
          instr.lazy = nil
        end
        instr
      end
      
      private
      def match(name, instr, bytes)
        instr.traits << name
        matcher = @namespaces[instr.namespace][name]
        instance_exec(instr, bytes, &matcher.proc)
      end
      
      def common(*args)
        cname = args.shift
        args[0].traits << cname
        instance_exec(*args, &@commons[cname])
      end
      
      def common_lazy(*args)
        args[1].lazy << args if args[1]
      end
      
      def load_ual
        instr_file = File.join(File.dirname(__FILE__), 'ual.inst.rb')
        dsl = self.class.dsl_parser.new
        dsl.instance_eval open(instr_file).read, instr_file, 1
        @namespaces = dsl.namespaces
        @commons = dsl.commons
      end
      
      def h
        @instructions_helper ||= UalInstructionsHelper.new
      end
      
      class << self
        def dsl_parser=(klass)
          @dsl_parser = klass
        end
        
        def dsl_parser
          @dsl_parser ||= UalTopLevelDSL
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
      attr_reader :namespaces, :commons
      
      def initialize
        @commons = {}
        @namespaces = Hash.new { |h,k| h[k] = Hash.new }
        @current_namespace = nil
      end
      
      def matcher(args, &block)
        matchers = @namespaces[@current_namespace]
        
        if args.is_a?(Hash)
          from = args.keys.first
          to = args[from]
          raise RuntimeError, "No parent matcher #{from} for matcher #{to}" unless matchers[from]
        else
          to = args
        end
        
        raise RuntimeError, "Matcher #{to} is already defined" if matchers[to]
        
        matchers[to] = Matcher.new(to, block)
      end
      
      def common(name, &block)
        raise RuntimeError, "Common block #{name} is already defined" if @commons[name]
        
        @commons[name] = block
      end
      
      def namespace(name, &block)
        @current_namespace = name
        yield
        @current_namespace = nil
      end
    end
    
    class DebugUalTopLevelDSL < UalTopLevelDSL
      def matcher(args, &block)
        if args.is_a?(Hash)
          from = args.keys.first
          to = args[from]
        else
          from = ''
          to = args
        end
        
        puts "matcher #{sprintf('%30s', from)} => #{to}"
        
        super
      end
      
      def common(name, &block)
        puts "common  #{name}"
        
        super
      end
    end
    
  end
end
