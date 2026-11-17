# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Inline identifier (e.g. a requirement path "/req/roles/…").
        class IdentifierElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :semx_id, :string
          attribute :text, :string, collection: true

          xml do
            element "identifier"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "semx-id", to: :semx_id
            map_content to: :text
          end
        end
      end
    end
  end
end
