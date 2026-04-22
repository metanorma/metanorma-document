# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module MultiParagraph
        # Author element inside a quote: <author id="...">text</author>
        class QuoteAuthorElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :text, :string

          xml do
            element "author"
            map_attribute "id", to: :id
            map_content to: :text
          end
        end

        # Block quotation, containing extensive textual content originally authored outside of the current
        # document.
        class QuoteBlock < ParagraphsBlock
          # Bibliographic citation for the quotation.
          attribute :source, Metanorma::Document::Components::ReferenceElements::ReferenceToCitationElement

          # Author of the quotation. The `author` attribute of the quotation is redundant with the citation,
          # since it restates information about the author that should be recoverable from the citation itself.
          # It is included for convenience, in case processing the citation to extract the author is prohibitive
          # for rendering tools.
          attribute :author, QuoteAuthorElement

          # Paragraphs within the quote.
          attribute :paragraphs,
                    Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true

          # Unordered lists within the quote.
          attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                    collection: true

          # Ordered lists within the quote.
          attribute :ol, Metanorma::Document::Components::Lists::OrderedList,
                    collection: true

          # Attribution for the quotation (presentation XML).
          attribute :attribution, "Metanorma::Document::Components::Inline::AttributionElement"

          attribute :json_type, :string

          def json_type
            "quote"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "source", to: :source
            map "author", to: :author
          end

          xml do
            element "quote"
            map_attribute "id", to: :id
            map_element "source", to: :source
            map_element "author", to: :author
            map_element "p", to: :paragraphs
            map_element "ul", to: :ul
            map_element "ol", to: :ol
            map_element "attribution", to: :attribution
          end
        end
      end
    end
  end
end
