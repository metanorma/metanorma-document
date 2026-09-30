# frozen_string_literal: true

module Metanorma
  module Html
    module Renderers
      autoload :ElementOrderTraversal,
               "metanorma/html/renderers/element_order_traversal"
      autoload :SemanticRenderer,
               "metanorma/html/renderers/semantic_renderer"
    end
  end
end
