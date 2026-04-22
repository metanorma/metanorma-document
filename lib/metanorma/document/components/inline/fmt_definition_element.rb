module Metanorma
  module Document
    module Components
      module Inline
        class FmtDefinitionElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :semx, SemxElement, collection: true

          xml do
            element "fmt-definition"
            map_attribute "id", to: :id
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
