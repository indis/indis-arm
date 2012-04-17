module Indis
  module ARM
    module Analyzer
      
      class Analyzer
        def initialize(target, evt)
          @target = target
          target.subscribe_for_event(evt, self)
        end
      end
      
    end
  end
end

require 'indis-arm/analyzer/bl_analyzer'
require 'indis-arm/analyzer/ldr_lit_analyzer'
