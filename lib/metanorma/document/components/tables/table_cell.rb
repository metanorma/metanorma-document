# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        # Shared XML mapping for TableCell and its <td>/<th> subclasses.
        # lutaml-model does not inherit xml mappings into a subclass's
        # `xml do` block — a bare redeclaration silently drops every
        # parent map_element (the #51 root cause: stems inside cells
        # parsed hollow). Each subclass applies this module after
        # declaring its element name.
        module TableCellXmlMapping
          module_function

          def apply(mapping)
            mapping.map_attribute "id", to: :id
            mapping.map_attribute "anchor", to: :anchor
            mapping.map_attribute "colspan", to: :colspan
            mapping.map_attribute "rowspan", to: :rowspan
            mapping.map_attribute "align", to: :align
            mapping.map_attribute "valign", to: :valign
            mapping.map_attribute "semx-id", to: :semx_id
            mapping.map_content to: :text
            mapping.map_element "em", to: :em
            mapping.map_element "strong", to: :strong
            mapping.map_element "tt", to: :tt
            mapping.map_element "sub", to: :sub
            mapping.map_element "sup", to: :sup
            mapping.map_element "smallcap", to: :smallcap
            mapping.map_element "br", to: :br
            mapping.map_element "xref", to: :xref
            mapping.map_element "eref", to: :eref
            mapping.map_element "link", to: :link
            mapping.map_element "stem", to: :stem
            mapping.map_element "fn", to: :fn
            mapping.map_element "strike", to: :strike
            mapping.map_element "underline", to: :underline
            mapping.map_element "p", to: :p
            mapping.map_element "dl", to: :dl
            mapping.map_element "ul", to: :ul
            mapping.map_element "ol", to: :ol
            mapping.map_element "figure", to: :figure
            mapping.map_element "formula", to: :formula
            mapping.map_element "note", to: :note
            mapping.map_element "example", to: :example
            mapping.map_element "quote", to: :quote
            mapping.map_element "sourcecode", to: :sourcecode
            mapping.map_element "source", to: :source
            mapping.map_element "table", to: :table
            mapping.map_element "key", to: :key
            mapping.map_element "fmt-stem", to: :fmt_stem
            mapping.map_element "fmt-fn-label", to: :fmt_fn_label
            mapping.map_element "semx", to: :semx
            mapping.map_element "span", to: :span
            mapping.map_element "bookmark", to: :bookmark
            mapping.map_element "input", to: :input
            mapping.map_element "fmt-annotation-start", to: :fmt_annotation_start
            mapping.map_element "fmt-annotation-end", to: :fmt_annotation_end
          end
        end

        # Base class for table cells with common attributes and mixed content.
        class TableCell < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :anchor, :string
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
          attribute :source,
                    Metanorma::Document::Components::ReferenceElements::SourceElement,
                    collection: true

          # Nested tables (table inside td/th). String-typed: breaks the
          # TableCell ⇄ TableBlock autoload cycle (cell → nested table →
          # rows → cells).
          attribute :table,
                    "Metanorma::Document::Components::Tables::TableBlock",
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
          attribute :input, Metanorma::Document::Elements::Input,
                    collection: true
          attribute :fmt_annotation_start,
                    Metanorma::Document::Components::Inline::FmtAnnotationStartElement, collection: true
          attribute :fmt_annotation_end,
                    Metanorma::Document::Components::Inline::FmtAnnotationEndElement, collection: true

          xml do
            mixed_content
            TableCellXmlMapping.apply(self)
          end
        end
      end
    end
  end
end
