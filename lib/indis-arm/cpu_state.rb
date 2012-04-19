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
    class CpuState
      16.times { |i| attr_accessor "r#{i}" }
      
      alias :sp :r13
      alias :sp= :r13=
      
      alias :lr :r14
      alias :lr= :r14=
      
      alias :pc :r15
      alias :pc= :r15=
      
      def initialize
        16.times { |i| self.send("r#{i}=", "value_r#{i}".to_sym) }
      end
      
      def to_s
        "#{rval 0}\t#{rval 4}\t#{rval 8}\t#{rval 12}\n" + 
        "#{rval 1}\t#{rval 5}\t#{rval 9}\t#{rval 13}\n" + 
        "#{rval 2}\t#{rval 6}\t#{rval 10}\t#{rval 14}\n"+ 
        "#{rval 3}\t#{rval 7}\t#{rval 11}\t#{rval 15}"
      end
      
      def write_to(regn, val)
        self.send("#{regn}=", val)
      end
      
      def read(regn)
        self.send(regn)
      end
      
      private
      A = [:r0, :r1, :r2, :r3, :r4, :r5, :r6, :r7, :r8, :r9, :r10, :r11, :r12, :sp, :lr, :pc]
      def rval(r)
        regn = A[r]
        val = self.send(regn)
        val = sprintf("%08x", val) if val.is_a?(Fixnum)
        "#{sprintf("%3s", regn)}: #{val}"
      end
    end
  end
end