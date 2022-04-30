# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # A note associated with the bibliographic item.
  class TypedNote < Core::Node
    include Core::Node::Custom

    register_element do
      # The class of the note associated with the bibliographic item.
      # May be used to differentiate rendering of notes in bibliographies.
      nodes :type, String

      # The content of the note.
      node :content, BasicDocument::FormattedString
    end
  end
end; end; end
