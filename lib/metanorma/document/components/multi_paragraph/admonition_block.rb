# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module MultiParagraph
        # A sidebar block outside of the main flow of text,
        # conveying particular warnings or supplementary text to the reader.
        class AdmonitionBlock < ParagraphsBlock
          # Subclass of admonition determining how it is to be rendered; e.g.
          # Warning, Note, Tip.
          # Distinct admonition types are often associated with distinct icons or rendering.
          attribute :type, :string

          # Caption of admonition.
          attribute :name, Metanorma::Document::Components::TextElements::TextElement,
                    collection: true

          # Subclass of admonition allowing different runs of admonitions to be labelled
          # and auto-numbered differently, even if they are of the same type.
          # Typically is a subclass of an admonition type.
          attribute :block_class, :string

          # Location where the content of the admonition is accessible as an external document.
          attribute :uri, :string

          # Paragraphs within the admonition.
          attribute :paragraphs,
                    Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true

          # Presentation-specific elements
          attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement

          attribute :json_type, :string

          def json_type
            "admonition"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "name", to: :name
            map "admonition_type", to: :type
          end

          xml do
            element "admonition"
            map_attribute "id", to: :id
            map_attribute "type", to: :type
            map_element "name", to: :name
            map_attribute "class", to: :block_class
            map_element "uri", to: :uri
            map_element "p", to: :paragraphs
            map_element "fmt-name", to: :fmt_name
          end
        end
      end
    end
  end
end
