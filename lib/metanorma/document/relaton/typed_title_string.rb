# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # A title of a bibliographic item, associated with a type of title.
  class TypedTitleString < Core::Node
    include Core::Node::Custom

    register_element do
      # The type for the given title of the bibliographic item.
      nodes :type, TitleType

      # The title itself.
      node :content, BasicDocument::FormattedString
    end
  end
end; end; end
