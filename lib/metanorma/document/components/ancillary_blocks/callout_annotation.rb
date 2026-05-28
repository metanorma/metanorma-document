# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        class CalloutAnnotation < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :original_id, :string
          attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true

          xml do
            element "callout-annotation"
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_attribute "original-id", to: :original_id
            map_element "p", to: :p
          end
        end
      end
    end
  end
end
