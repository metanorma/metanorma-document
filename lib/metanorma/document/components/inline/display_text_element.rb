module Metanorma
  module Document
    module Components
      module Inline
        class DisplayTextElement < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
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

          xml do
            element "display-text"
            mixed_content
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
          end
        end
      end
    end
  end
end
