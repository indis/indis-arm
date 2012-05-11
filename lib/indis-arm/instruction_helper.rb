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

require 'indis-core/binaryops_string'

module Indis
  module ARM
    class UalInstructionsHelper
      def bits_array(i)
        i.to_s(2).reverse!.split('').each_with_index.map { |val,idx| val == '1' ? idx : nil }.compact
      end
      
      def ZeroExtend(bits_x, i)
        bits_x.to_bo.zero_extend(i).to_i
      end
      
      def SignExtend(bits_x, i)
        bits_x.to_bo.sign_extend(i).to_signed_i
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
      
      def cond_to_mnemonic(cond)
        return '' unless cond
        mnem = ['eq', 'ne', 'cs', 'cc', 'mi', 'pl', 'vs', 'vc', 'hi', 'ls', 'ge', 'lt', 'gt', 'le', '']
        mnem[cond]
      end
    end
    
    module PseudoCodeInstructionHelper
      def ARMExpandImm(bits_imm12) # A5.2.4
        ARMExpandImm_C(bits_imm12, 0)[0] # FIXME APSR.C ???
      end
      
      def ARMExpandImm_C(bits_imm12, carry_in) # A5.2.4
        unrotated_value = bits_imm12.bits(7, 0).zero_extend(32)
        Shift_C(unrotated_value, :SRType_ROR, 2*(bits_imm12.bits(11, 8).to_i), carry_in)
      end
      
      def DecodeImmShift(bits2_type, bits5_imm5)
        imm = bits5_imm5.to_i
        case bits2_type.to_i
        when 0b00
          [:SRType_LSL, imm]
        when 0b01
          [:SRType_LSR, imm == 0 ? 32 : imm]
        when 0b10
          [:SRType_ASR, imm == 0 ? 32 : imm]
        when 0b11
          imm == 0 ? [:SRType_RRX, 1] : [:SRType_ROR, imm]
        end    
      end
      
      def ZeroExtend(bits_x, i) # P5.3
        bits_x.zero_extend(i)
      end
      
      def SignExtend(bits_x, i) # P5.3
        bits_x.sign_extend(i)
      end
      
      def Shift_C(bits_value, type, amount, carry_in) # A8.4.3
        raise ArgumentError unless !(type == :SRType_RRX && amount != 1)
        
        return [bits_value, carry_in] if amount == 0
        
        case type
        when :SRType_LSL
          LSL_C(bits_value, amount)
        when :SRType_LSR
          LSR_C(bits_value, amount)
        when :SRType_ASR
          ASR_C(bits_value, amount)
        when :SRType_ROR
          ROR_C(bits_value, amount)
        when :SRType_RRX
          RRX_C(bits_value, carry_in)
        end   
      end
      
      def ROR_C(bits_x, shift) # A2.2.1
        raise ArgumentError unless shift != 0
        
        [bits_x.ror(shift), bits_x.rbit(0)]
      end
      
      def LSR(bits_x, shift) # A2.2.1
        raise ArgumentError unless shift >= 0
        bits_x >> shift
      end
      
      def LSR_C(bits_x, shift) # A2.2.1
        raise ArgumentError unless shift > 0
        [bits_x >> shift, bits_x.bit(shift-1)]
      end
      
      def LSL(bits_x, shift) # A2.2.1
        raise ArgumentError unless shift >= 0
        bits_x << shift
      end
      
      def LSL_C(bits_x, shift) # A2.2.1
        raise ArgumentError unless shift > 0
        [bits_x << shift, bits_x.bit(shift)]
      end
    end
    
    module InstructionHelper
      class << self
        COND = [".EQ", ".NE", ".CS", ".CC", ".MI", ".PL", ".VS", ".VC", ".HI", ".LS", ".GE", ".LT", ".GT", ".LE", ""]
        COND_SYM = [:eq, :ne, :cs, :cc, :mi, :pl, :vs, :vc, :hi, :ls, :ge, :lt, :gt, :le, :al]
        NAMED_REG = { r13: :sp, r14: :lr, r15: :pc }
        REG = [:r0, :r1, :r2, :r3, :r4, :r5, :r6, :r7, :r8, :r9, :r10, :r11, :r12, :r13, :r14, :r15]
        SHIFT_TYPES = {
          SRType_LSL: :lsl,
          SRType_LSR: :lsr,
          SRType_ASR: :asr,
          SRType_ROR: :ror,
          SRType_RRX: :rrx,
        }
        
        def regs_from_bits(bits_list)
          bl = bits_list.to_s(2)
          bl = ('0'*(16-bl.length)) + bl
          regs = []
          bl.reverse! # XXX so that r0 is bit 0
          bl.length.times do |i| 
            regs << "r#{i}".to_sym if bl[i] == '1'
          end
          regs.map { |r| NAMED_REG[r] || r }
        end
        
        def shift_type_to_s(shift)
          SHIFT_TYPES[shift]
        end
        
        def cond_to_s(cond)
          ('.' + cond.to_s.upcase).sub('.AL', '')
        end
        
        def regs_to_s(regs)
          regs = regs.map { |r| NAMED_REG[r] || r }
          regs.join(', ')
        end
        
        def flag(f, fn)
          f ? fn : ''
        end
        
        def reg(i)
          r = REG[i]
          NAMED_REG[r] || r
        end
        
        def cond(i)
          COND_SYM[i]
        end
        
        include PseudoCodeInstructionHelper
      end
    end
  end
end