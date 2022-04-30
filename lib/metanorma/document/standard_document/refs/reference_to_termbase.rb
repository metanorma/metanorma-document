# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Cross-reference to a term defined within a termbase.
  class ReferenceToTermbase < Core::Node
    include Core::Node::Custom

    register_element do
      # Identifier of the termbase.
      attribute :base, String

      # Identifier of the term within the termbase.
      attribute :target, String

      # Text to display for the cross-reference to the term.
      node :text, BasicDocument::TextElement
    end
  end
end; end; end
