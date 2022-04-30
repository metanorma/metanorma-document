# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Definition used to constitute a definition list.
  class Definition < Core::Node
    include Core::Node::Custom

    register_element "dd" do
      # Entry being defined in the definition.
      nodes :item, TextElement

      # Definition of the item.
      nodes :definition, ParagraphWithFootnote
    end
  end
end; end; end
