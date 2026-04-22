# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Strikethrough text. Corresponds to HTML 4 `s`.
        # Contains mixed content with inline elements.
        class StrikeElement < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :em, "Metanorma::Document::Components::Inline::EmRawElement",
                    collection: true
          attribute :strong, "Metanorma::Document::Components::Inline::StrongRawElement",
                    collection: true
          attribute :eref, "Metanorma::Document::Components::Inline::ErefElement",
                    collection: true
          attribute :link, "Metanorma::Document::Components::Inline::LinkElement",
                    collection: true

          xml do
            element "strike"
            mixed_content
            map_content to: :text
            map_element "em", to: :em
            map_element "strong", to: :strong
            map_element "eref", to: :eref
            map_element "link", to: :link
          end
        end
      end
    end
  end
end
