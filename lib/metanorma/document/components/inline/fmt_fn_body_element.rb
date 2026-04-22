module Metanorma
  module Document
    module Components
      module Inline
        class FmtFnBodyElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :target, :string
          attribute :reference, :string
          attribute :semx, SemxElement

          xml do
            element "fmt-fn-body"
            map_attribute "id", to: :id
            map_attribute "target", to: :target
            map_attribute "reference", to: :reference
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
