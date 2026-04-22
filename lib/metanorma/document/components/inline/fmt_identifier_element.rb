module Metanorma
  module Document
    module Components
      module Inline
        class FmtIdentifierElement < Lutaml::Model::Serializable
          attribute :tt, TtElement, collection: true

          xml do
            element "fmt-identifier"
            map_element "tt", to: :tt
          end
        end
      end
    end
  end
end
