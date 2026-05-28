# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module MultiParagraph
        class QuoteBlock < ParagraphsBlock
          attribute :source, Metanorma::Document::Components::ReferenceElements::ReferenceToCitationElement
          attribute :author, QuoteAuthorElement
          attribute :paragraphs,
                    Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true
          attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                    collection: true
          attribute :ol, Metanorma::Document::Components::Lists::OrderedList,
                    collection: true
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
