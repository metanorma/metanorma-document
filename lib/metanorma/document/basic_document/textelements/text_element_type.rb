# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Content of the Text Element.
  class TextElementType < Core::Node
    include Core::Node::Custom

    register_element do
      # Textual content of the Text Element.
      nodes :content, LocalizedString

      # May recursively contain other Text Elements.
      nodes :elements, TextElement
    end
  end
end; end; end
