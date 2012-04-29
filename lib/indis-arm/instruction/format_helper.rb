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
    
    module FormatHelper
      private
      def process_formatter(val)
        (fmt, val) = val.split(':',2)
        fmt_sym = fmt.to_sym
        if val
          format_value(fmt_sym, val)
        else
          if fmt[0] == 'r'
            register_to_s(self.values[fmt_sym])
          else
            self.values[fmt_sym]
          end
        end
      end
        
      def format_value(fmt, val)
        processed_val = process_formatter(val)
        case fmt
        when :offset_from_pc
          @vmaddr + 4 + processed_val
        when :hex
          '0x' + processed_val.to_s(16)
        else
          raise RuntimeError, "Unknown formatter #{fmt} for #{val}, with traits #{@traits}"
        end
      end
      
      def operands_subst
        o = @operands.dup
        while o.index('{')
          o.gsub!(/{{[^}]+}}/) do |mstr|
            argn = mstr[2...-2]
            process_formatter(argn)
          end
        end
        o
      end
      
      def register_to_s(regn)
        names = %w(r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 sl fp ip sp lr pc)
        names[regn]
      end
    end
    
  end
end