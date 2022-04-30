# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # A designation realised as a letter or symbol.
  class LetterSymbolDesignation < Core::Node
    include Core::Node::Custom

    register_element "letter-symbol" do
      # The textual form of the designation.
      nodes :text, String

      # The mathematical form of the designation.
      node :stem, BasicDocument::StemElement

      # Whether the designation (typically an abbreviation) is the same across languages, or
      # language-specific.
      attribute :is_international, TrueClass, xml_attribute: "isInternational"
    end
  end
end; end; end
