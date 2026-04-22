module Metanorma
  module Document
    module Components
      module Inline
        class LinkElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :target, :string
          attribute :update_type, :string
          attribute :style, :string
          attribute :content, :string, collection: true
          attribute :link, LinkElement, collection: true

          xml do
            element "link"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "target", to: :target
            map_attribute "update-type", to: :update_type
            map_attribute "style", to: :style
            map_content to: :content
            map_element "link", to: :link
          end
        end
      end
    end
  end
end
