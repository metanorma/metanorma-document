# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        # Definition description element, containing paragraphs.
        class DdElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :semx_id, :string
          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true
          attribute :ul, UnorderedList,
                    collection: true
          attribute :ol, OrderedList,
                    collection: true
          attribute :sourcecode, "Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock",
                    collection: true
          attribute :figure, "Metanorma::Document::Components::AncillaryBlocks::FigureBlock",
                    collection: true
          attribute :example, "Metanorma::Document::Components::AncillaryBlocks::ExampleBlock",
                    collection: true
          attribute :note, "Metanorma::Document::Components::Blocks::NoteBlock",
                    collection: true
          attribute :table, "Metanorma::Document::Components::Tables::TableBlock",
                    collection: true
          attribute :formula, "Metanorma::Document::Components::AncillaryBlocks::FormulaBlock",
                    collection: true
          attribute :quote, "Metanorma::Document::Components::MultiParagraph::QuoteBlock",
                    collection: true
          attribute :dl, DefinitionList,
                    collection: true
          attribute :semx, "Metanorma::Document::Components::Inline::SemxElement"
          attribute :fmt_fn_body, "Metanorma::Document::Components::Inline::FmtFnBodyElement"

          xml do
            element "dd"
            map_attribute "id", to: :id
            map_attribute "semx-id", to: :semx_id
            map_element "p", to: :p
            map_element "ul", to: :ul
            map_element "ol", to: :ol
            map_element "sourcecode", to: :sourcecode
            map_element "figure", to: :figure
            map_element "example", to: :example
            map_element "note", to: :note
            map_element "table", to: :table
            map_element "formula", to: :formula
            map_element "quote", to: :quote
            map_element "dl", to: :dl
            map_element "semx", to: :semx
            map_element "fmt-fn-body", to: :fmt_fn_body
          end
        end
      end
    end
  end
end
