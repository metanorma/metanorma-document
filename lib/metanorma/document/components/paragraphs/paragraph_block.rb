# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Paragraphs
        # Default block of textual content.
        class ParagraphBlock < Metanorma::Document::Components::Blocks::BasicBlock
          attribute :id, :string
          attribute :anchor, :string
          attribute :alignment, :string
          attribute :semx_id, :string
          attribute :original_id, :string
          attribute :keep_with_next, :string
          attribute :class_attr, :string
          attribute :type_attr, :string
          attribute :displayorder, :integer
          attribute :text, :string, collection: true

          # Inline elements
          attribute :em, Metanorma::Document::Components::Inline::EmRawElement,
                    collection: true
          attribute :strong, Metanorma::Document::Components::Inline::StrongRawElement,
                    collection: true
          attribute :smallcap, Metanorma::Document::Components::Inline::SmallCapElement,
                    collection: true
          attribute :sub, Metanorma::Document::Components::Inline::SubElement,
                    collection: true
          attribute :sup, Metanorma::Document::Components::Inline::SupElement,
                    collection: true
          attribute :tt, Metanorma::Document::Components::Inline::TtElement,
                    collection: true
          attribute :underline, Metanorma::Document::Components::TextElements::UnderlineElement,
                    collection: true
          attribute :strike, Metanorma::Document::Components::TextElements::StrikeElement,
                    collection: true
          attribute :keyword, :string, collection: true
          attribute :fmt_annotation_end,
                    Metanorma::Document::Components::Inline::FmtAnnotationEndElement, collection: true
          attribute :fmt_annotation_start,
                    Metanorma::Document::Components::Inline::FmtAnnotationStartElement, collection: true
          attribute :br, Metanorma::Document::Components::Inline::BrElement,
                    collection: true
          attribute :xref, Metanorma::Document::Components::Inline::XrefElement,
                    collection: true
          attribute :eref, Metanorma::Document::Components::Inline::ErefElement,
                    collection: true
          attribute :link, Metanorma::Document::Components::Inline::LinkElement,
                    collection: true
          attribute :span, Metanorma::Document::Components::Inline::SpanElement,
                    collection: true
          attribute :stem, Metanorma::Document::Components::Inline::StemInlineElement,
                    collection: true
          attribute :concept, Metanorma::Document::Components::Inline::ConceptElement,
                    collection: true
          attribute :fn, Metanorma::Document::Components::Inline::FnElement,
                    collection: true
          attribute :note, Metanorma::Document::Components::Blocks::NoteBlock,
                    collection: true
          attribute :semx, Metanorma::Document::Components::Inline::SemxElement,
                    collection: true
          attribute :tab, Metanorma::Document::Components::Inline::TabElement,
                    collection: true
          attribute :fmt_stem, Metanorma::Document::Components::Inline::FmtStemElement,
                    collection: true
          attribute :fmt_fn_label,
                    Metanorma::Document::Components::Inline::FmtFnLabelElement, collection: true
          attribute :fmt_concept,
                    Metanorma::Document::Components::Inline::FmtConceptElement, collection: true
          attribute :bookmark, Metanorma::Document::Components::IdElements::Bookmark,
                    collection: true
          attribute :image, Metanorma::Document::Components::IdElements::Image,
                    collection: true
          attribute :add, "Metanorma::StandardDocument::Elements::Add",
                    collection: true
          attribute :del, "Metanorma::StandardDocument::Elements::Del",
                    collection: true

          # JSON serialization attributes
          attribute :json_type, :string
          attribute :json_content, :string

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "content", to: :json_content
          end

          xml do
            element "p"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "align", to: :alignment
            map_attribute "semx-id", to: :semx_id
            map_attribute "original-id", to: :original_id
            map_attribute "keep-with-next", to: :keep_with_next
            map_attribute "class", to: :class_attr
            map_attribute "type", to: :type_attr
            map_attribute "displayorder", to: :displayorder
            map_content to: :text
            map_element "em", to: :em
            map_element "strong", to: :strong
            map_element "smallcap", to: :smallcap
            map_element "sub", to: :sub
            map_element "sup", to: :sup
            map_element "tt", to: :tt
            map_element "underline", to: :underline
            map_element "strike", to: :strike
            map_element "keyword", to: :keyword
            map_element "br", to: :br
            map_element "xref", to: :xref
            map_element "eref", to: :eref
            map_element "link", to: :link
            map_element "span", to: :span
            map_element "stem", to: :stem
            map_element "concept", to: :concept
            map_element "fn", to: :fn
            map_element "note", to: :note
            map_element "fmt-annotation-end", to: :fmt_annotation_end
            map_element "fmt-annotation-start", to: :fmt_annotation_start
            map_element "semx", to: :semx
            map_element "tab", to: :tab
            map_element "fmt-stem", to: :fmt_stem
            map_element "fmt-fn-label", to: :fmt_fn_label
            map_element "fmt-concept", to: :fmt_concept
            map_element "bookmark", to: :bookmark
            map_element "image", to: :image
            map_element "add", to: :add
            map_element "del", to: :del
          end

          def json_content
            t = text
            if t
              joined = t.is_a?(Array) ? t.join : t
              return joined unless joined.strip.empty?
            end
            ""
          end

          def json_type
            "paragraph"
          end
        end
      end
    end
  end
end
