# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        # Definition term element, supporting inline content like stem, tt, etc.
        class DtElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :stem, "Metanorma::Document::Components::TextElements::StemElement"
          attribute :fmt_stem, "Metanorma::Document::Components::Inline::FmtStemElement"
          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true
          attribute :span, "Metanorma::Document::Components::Inline::SpanElement",
                    collection: true
          attribute :tt, "Metanorma::Document::Components::Inline::TtElement",
                    collection: true
          attribute :em, "Metanorma::Document::Components::Inline::EmRawElement",
                    collection: true
          attribute :strong, "Metanorma::Document::Components::Inline::StrongRawElement",
                    collection: true
          attribute :sub, :string, collection: true
          attribute :sup, "Metanorma::Document::Components::Inline::SupElement",
                    collection: true
          attribute :xref, "Metanorma::Document::Components::Inline::XrefElement",
                    collection: true
          attribute :eref, "Metanorma::Document::Components::Inline::ErefElement",
                    collection: true
          attribute :link, "Metanorma::Document::Components::Inline::LinkElement",
                    collection: true
          attribute :strike, "Metanorma::Document::Components::TextElements::StrikeElement",
                    collection: true
          attribute :underline, "Metanorma::Document::Components::TextElements::UnderlineElement",
                    collection: true
          attribute :br, "Metanorma::Document::Components::Inline::BrElement",
                    collection: true
          attribute :fn, "Metanorma::Document::Components::Inline::FnElement",
                    collection: true
          attribute :content, :string, collection: true

          xml do
            element "dt"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_element "stem", to: :stem
            map_element "fmt-stem", to: :fmt_stem
            map_element "p", to: :p
            map_element "span", to: :span
            map_element "tt", to: :tt
            map_element "em", to: :em
            map_element "strong", to: :strong
            map_element "sub", to: :sub
            map_element "sup", to: :sup
            map_element "xref", to: :xref
            map_element "eref", to: :eref
            map_element "link", to: :link
            map_element "strike", to: :strike
            map_element "underline", to: :underline
            map_element "br", to: :br
            map_element "fn", to: :fn
            map_content to: :content
          end
        end
      end
    end
  end
end
