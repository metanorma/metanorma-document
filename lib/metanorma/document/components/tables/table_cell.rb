# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        # Base class for table cells with common attributes and mixed content.
        class TableCell < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :colspan, :integer
          attribute :rowspan, :integer
          attribute :align, :string
          attribute :valign, :string
          attribute :text, :string, collection: true

          # Inline elements
          attribute :em, Metanorma::Document::Components::Inline::EmRawElement,
                    collection: true
          attribute :strong, Metanorma::Document::Components::Inline::StrongRawElement,
                    collection: true
          attribute :tt, Metanorma::Document::Components::Inline::TtElement,
                    collection: true
          attribute :sub, Metanorma::Document::Components::Inline::SubElement,
                    collection: true
          attribute :sup, Metanorma::Document::Components::Inline::SupElement,
                    collection: true
          attribute :smallcap, :string, collection: true
          attribute :br, Metanorma::Document::Components::Inline::BrElement,
                    collection: true
          attribute :xref, Metanorma::Document::Components::Inline::XrefElement,
                    collection: true
          attribute :eref, Metanorma::Document::Components::Inline::ErefElement,
                    collection: true
          attribute :link, Metanorma::Document::Components::Inline::LinkElement,
                    collection: true
          attribute :stem,
                    Metanorma::Document::Components::Inline::StemInlineElement, collection: true
          attribute :fn, Metanorma::Document::Components::Inline::FnElement,
                    collection: true
          attribute :strike, Metanorma::Document::Components::TextElements::StrikeElement,
                    collection: true
          attribute :underline, Metanorma::Document::Components::TextElements::UnderlineElement,
                    collection: true
          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true
          attribute :dl, "Metanorma::Document::Components::Lists::DefinitionList",
                    collection: true
          attribute :ul, "Metanorma::Document::Components::Lists::UnorderedList",
                    collection: true
          attribute :ol, "Metanorma::Document::Components::Lists::OrderedList",
                    collection: true
          attribute :figure, "Metanorma::Document::Components::AncillaryBlocks::FigureBlock",
                    collection: true
          attribute :formula, "Metanorma::Document::Components::AncillaryBlocks::FormulaBlock",
                    collection: true
          attribute :note, "Metanorma::Document::Components::Blocks::NoteBlock",
                    collection: true
          attribute :example, "Metanorma::Document::Components::AncillaryBlocks::ExampleBlock",
                    collection: true
          attribute :quote, "Metanorma::Document::Components::MultiParagraph::QuoteBlock",
                    collection: true
          attribute :sourcecode, "Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock",
                    collection: true
          attribute :source, "Metanorma::IsoDocument::Terms::TermSource",
                    collection: true

          # Nested tables (table inside td/th)
          attribute :table, TableBlock,
                    collection: true

          # Key definitions inside table cells
          attribute :key, "Metanorma::Document::Components::AncillaryBlocks::KeyElement"

          # Presentation-specific elements
          attribute :semx_id, :string
          attribute :fmt_stem,
                    Metanorma::Document::Components::Inline::FmtStemElement, collection: true
          attribute :fmt_fn_label,
                    Metanorma::Document::Components::Inline::FmtFnLabelElement, collection: true
          attribute :semx, Metanorma::Document::Components::Inline::SemxElement,
                    collection: true
          attribute :span, Metanorma::Document::Components::Inline::SpanElement,
                    collection: true
          attribute :bookmark, Metanorma::Document::Components::IdElements::Bookmark,
                    collection: true
          attribute :fmt_annotation_start,
                    Metanorma::Document::Components::Inline::FmtAnnotationStartElement, collection: true
          attribute :fmt_annotation_end,
                    Metanorma::Document::Components::Inline::FmtAnnotationEndElement, collection: true

          xml do
            mixed_content
            map_attribute "id", to: :id
            map_attribute "colspan", to: :colspan
            map_attribute "rowspan", to: :rowspan
            map_attribute "align", to: :align
            map_attribute "valign", to: :valign
            map_attribute "semx-id", to: :semx_id
            map_content to: :text
            map_element "em", to: :em
            map_element "strong", to: :strong
            map_element "tt", to: :tt
            map_element "sub", to: :sub
            map_element "sup", to: :sup
            map_element "smallcap", to: :smallcap
            map_element "br", to: :br
            map_element "xref", to: :xref
            map_element "eref", to: :eref
            map_element "link", to: :link
            map_element "stem", to: :stem
            map_element "fn", to: :fn
            map_element "strike", to: :strike
            map_element "underline", to: :underline
            map_element "p", to: :p
            map_element "dl", to: :dl
            map_element "ul", to: :ul
            map_element "ol", to: :ol
            map_element "figure", to: :figure
            map_element "formula", to: :formula
            map_element "note", to: :note
            map_element "example", to: :example
            map_element "quote", to: :quote
            map_element "sourcecode", to: :sourcecode
            map_element "source", to: :source
            map_element "table", to: :table
            map_element "key", to: :key
            map_element "fmt-stem", to: :fmt_stem
            map_element "fmt-fn-label", to: :fmt_fn_label
            map_element "semx", to: :semx
            map_element "span", to: :span
            map_element "bookmark", to: :bookmark
            map_element "fmt-annotation-start", to: :fmt_annotation_start
            map_element "fmt-annotation-end", to: :fmt_annotation_end
          end
        end
      end
    end
  end
end
