# frozen_string_literal: true

require "metanorma/document/basic_document/multiparagraphs/paragraphs_block"

module Metanorma; module Document; module BasicDocument
  # A sidebar block outside of the main flow of text,
  # conveying particular warnings or supplementary text to the reader.
  class AdmonitionBlock < ParagraphsBlock
    register_element "admonition" do
      # Subclass of admonition determining how it is to be rendered; e.g.
      # Warning, Note, Tip.
      # Distinct admonition types are often associated with distinct icons or rendering.
      attribute :type, AdmonitionType

      # Caption of admonition.
      nodes :name, TextElement

      # Subclass of admonition allowing different runs of admonitions to be labelled
      # and auto-numbered differently, even if they are of the same type.
      # Typically is a subclass of an admonition type.
      attribute :class, String

      # Location where the content of the admonition is accessible as an external document.
      attribute :uri, Uri
    end
  end
end; end; end
