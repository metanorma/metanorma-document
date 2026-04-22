module Metanorma
  module Document
    module Components
      module Inline
        class TitleWithAnnotationElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :semx_id, :string
          attribute :text, :string, collection: true
          attribute :fmt_annotation_end, FmtAnnotationBodyElement

          # Inline elements
          attribute :em, EmRawElement, collection: true
          attribute :strong, StrongRawElement, collection: true
          attribute :sub, SubElement, collection: true
          attribute :sup, SupElement, collection: true
          attribute :tt, TtElement, collection: true
          attribute :underline, "Metanorma::Document::Components::TextElements::UnderlineElement",
                    collection: true
          attribute :strike, "Metanorma::Document::Components::TextElements::StrikeElement",
                    collection: true
          attribute :smallcap, SmallCapElement, collection: true
          attribute :br, BrElement, collection: true
          attribute :xref, XrefElement, collection: true
          attribute :eref, ErefElement, collection: true
          attribute :link, LinkElement, collection: true

          xml do
            element "title"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "semx-id", to: :semx_id
            map_content to: :text
            map_element "em", to: :em
            map_element "strong", to: :strong
            map_element "sub", to: :sub
            map_element "sup", to: :sup
            map_element "tt", to: :tt
            map_element "underline", to: :underline
            map_element "strike", to: :strike
            map_element "smallcap", to: :smallcap
            map_element "br", to: :br
            map_element "xref", to: :xref
            map_element "eref", to: :eref
            map_element "link", to: :link
            map_element "fmt-annotation-end", to: :fmt_annotation_end
          end
        end
      end
    end
  end
end
