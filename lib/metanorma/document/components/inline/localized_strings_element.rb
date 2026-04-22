module Metanorma
  module Document
    module Components
      module Inline
        class LocalizedStringsElement < Lutaml::Model::Serializable
          attribute :localized_string, LocalizedStringElement, collection: true

          xml do
            element "localized-strings"
            map_element "localized-string", to: :localized_string
          end
        end
      end
    end
  end
end
