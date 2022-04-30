# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The actual content
  # changes that applies to the specified portion of textual content.
  # This is used both by the _ContentModify_ and _AttributeModify_ models
  # as their content are treated as pure text.
  class ContentChangeAction < Core::Node
    include Core::Node::Custom

    register_element do
      # Indication that text is to be inserted or deleted from the content.
      attribute :action, ContentAction

      # An `Integer` that specifies the beginning cursor position of a textual change.
      attribute :from, Integer

      # An `Integer` that specifies the ending cursor position of a textual change.
      attribute :to, Integer

      # In the case of an `insert`, a `String` to be inserted or replace the substring referred to by `from`
      # to `to`.
      attribute :text, String

      # In the case of a `delete`, an `Integer` to indicate how many characters to be removed from the
      # `from` position.
      # In the case of an `insert`, an `Integer` to indicate the length of the `text` attribute.
      attribute :length, Integer
    end
  end
end; end; end
