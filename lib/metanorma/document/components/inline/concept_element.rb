module Metanorma
  module Document
    module Components
      module Inline
        class ConceptElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :refterm, :string, collection: true
          attribute :renderterm, :string, collection: true
          attribute :xref, XrefElement, collection: true

          xml do
            element "concept"
            map_attribute "id", to: :id
            map_element "refterm", to: :refterm
            map_element "renderterm", to: :renderterm
            map_element "xref", to: :xref
          end
        end
      end
    end
  end
end
