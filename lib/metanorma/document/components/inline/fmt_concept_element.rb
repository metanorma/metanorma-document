module Metanorma
  module Document
    module Components
      module Inline
        class FmtConceptElement < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :semx, SemxElement, collection: true
          attribute :eref, ErefElement, collection: true
          attribute :xref, XrefElement, collection: true

          xml do
            element "fmt-concept"
            mixed_content
            map_content to: :text
            map_element "semx", to: :semx
            map_element "eref", to: :eref
            map_element "xref", to: :xref
          end
        end
      end
    end
  end
end
