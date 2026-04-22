module Metanorma
  module Document
    module Components
      module Inline
        class SemxChildElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :semx_id, :string
          attribute :original_id, :string
          attribute :type, :string
          attribute :status, :string
          attribute :content, :string

          xml do
            map_attribute "id", to: :id
            map_attribute "semx-id", to: :semx_id
            map_attribute "original-id", to: :original_id
            map_attribute "type", to: :type
            map_attribute "status", to: :status
            map_all_content to: :content
          end
        end
      end
    end
  end
end
