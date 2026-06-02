# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class NameWithIdElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :semx_id, :string
          attribute :text, :string
          attribute :stem, TextElements::StemElement, collection: true

          xml do
            element "name"
            map_attribute "id", to: :id
            map_attribute "semx-id", to: :semx_id
            map_content to: :text
            map_element "stem", to: :stem
          end
        end
      end
    end
  end
end
