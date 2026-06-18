# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Leaf < Node
        def leaf?
          true
        end

        def accept_rewriter(rewriter)
          rewriter.rewrite_leaf(self)
        end
      end
    end
  end
end
