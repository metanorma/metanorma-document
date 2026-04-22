# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        # Note block, modelled to consist only of paragraphs.
        class NoteBlock < BasicBlockNoNotes
          attribute :content, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true

          attribute :formula,
                    "Metanorma::Document::Components::AncillaryBlocks::FormulaBlock",
                    collection: true

          attribute :dl,
                    "Metanorma::Document::Components::Lists::DefinitionList"

          attribute :ul,
                    "Metanorma::Document::Components::Lists::UnorderedList",
                    collection: true
          attribute :ol,
                    "Metanorma::Document::Components::Lists::OrderedList",
                    collection: true

          attribute :quote,
                    "Metanorma::Document::Components::MultiParagraph::QuoteBlock",
                    collection: true

          attribute :json_type, :string
          attribute :type_attr, :string
          attribute :format, :string
          attribute :semx_id, :string
          attribute :autonum, :string

          def json_type
            "note"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "content", to: :content
          end

          attribute :anchor, :string

          attribute :remove_in_rfc, :string

          attribute :fmt_xref_label,
                    Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true
          attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement

          xml do
            element "note"
            map_attribute "type", to: :type_attr
            map_attribute "format", to: :format
            map_attribute "semx-id", to: :semx_id
            map_attribute "autonum", to: :autonum, render_empty: true
            map_attribute "anchor", to: :anchor
            map_attribute "removeInRFC", to: :remove_in_rfc
            map_element "p", to: :content
            map_element "formula", to: :formula
            map_element "dl", to: :dl
            map_element "ul", to: :ul
            map_element "ol", to: :ol
            map_element "quote", to: :quote
            map_element "fmt-xref-label", to: :fmt_xref_label
            map_element "fmt-name", to: :fmt_name
          end
        end
      end
    end
  end
end
