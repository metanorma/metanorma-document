# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Leaf < Node
        def leaf?
          true
        end
      end
    end
  end
end
