# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module MultiParagraph
      # A sidebar block outside of the main flow of text,
      # conveying particular warnings or supplementary text to the reader.
      class AdmonitionBlock < Metanorma::BasicDocument::MultiParagraph::ParagraphsBlock
        # Subclass of admonition determining how it is to be rendered; e.g.
        # Warning, Note, Tip.
        # Distinct admonition types are often associated with distinct icons or rendering.
        attribute :type, :string

        # Caption of admonition.
        attribute :name, Metanorma::BasicDocument::TextElements::TextElement,
                  collection: true

        # Subclass of admonition allowing different runs of admonitions to be labelled
        # and auto-numbered differently, even if they are of the same type.
        # Typically is a subclass of an admonition type.
        attribute :class, :string

        # Location where the content of the admonition is accessible as an external document.
        attribute :uri, Metanorma::Document::Components::DataTypes::Uri

        xml do
          element "admonition"
          map_attribute "type", to: :type
          map_element "name", to: :name
          map_attribute "class", to: :class
          map_element "uri", to: :uri
        end
      end
    end
  end
end
