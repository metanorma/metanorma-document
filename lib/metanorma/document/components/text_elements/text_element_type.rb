# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Content of the Text Element.
        class TextElementType < Lutaml::Model::Serializable
          attribute :content, Metanorma::Document::Components::DataTypes::LocalizedString
          attribute :elements, TextElement, collection: true

          xml do
            element "text-element-type"
            map_element "content", to: :content
            map_element "elements", to: :elements
          end
        end
      end
    end
  end
end
