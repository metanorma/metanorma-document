module Metanorma
  module Document
    module Components
      module Inline
        class XrefElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :target, :string
          attribute :style, :string
          attribute :format, :string
          attribute :text, :string, collection: true

          xml do
            element "xref"
            map_attribute "id", to: :id
            map_attribute "target", to: :target
            map_attribute "style", to: :style
            map_attribute "format", to: :format
            map_content to: :text
          end
        end
      end
    end
  end
end
