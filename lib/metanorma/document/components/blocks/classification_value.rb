# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        class ClassificationValue < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :link, Metanorma::Document::Components::Inline::LinkElement,
                    collection: true

          xml do
            mixed_content
            map_content to: :text
            map_element "link", to: :link
          end
        end
      end
    end
  end
end
