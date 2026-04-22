module Metanorma
  module Document
    module Components
      module Inline
        class XrefElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :target, :string
          attribute :style, :string

          xml do
            element "xref"
            map_attribute "id", to: :id
            map_attribute "target", to: :target
            map_attribute "style", to: :style
          end
        end
      end
    end
  end
end
