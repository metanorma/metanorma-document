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
          attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                    collection: true
          attribute :note, Metanorma::Document::Components::Blocks::NoteBlock,
                    collection: true
          attribute :dl, Metanorma::Document::Components::Lists::DefinitionList,
                    collection: true
          attribute :formula,
                    Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                    collection: true
          attribute :bookmark, Metanorma::Document::Components::IdElements::Bookmark,
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
            map_element "table", to: :table
            map_element "note", to: :note
            map_element "dl", to: :dl
            map_element "formula", to: :formula
            map_element "bookmark", to: :bookmark
            map_element "attribution", to: :attribution
          end
        end
      end
    end
  end
end
