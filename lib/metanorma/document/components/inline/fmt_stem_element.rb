module Metanorma
  module Document
    module Components
      module Inline
        class FmtStemElement < Lutaml::Model::Serializable
          attribute :stem_type, :string
          attribute :semx, SemxElement, collection: true

          xml do
            element "fmt-stem"
            map_attribute "type", to: :stem_type
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
