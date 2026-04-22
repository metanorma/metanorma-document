module Metanorma
  module Document
    module Components
      module Inline
        class FmtTermsourceElement < Lutaml::Model::Serializable
          attribute :status, :string
          attribute :type, :string
          attribute :semx, SemxElement

          xml do
            element "fmt-termsource"
            map_attribute "status", to: :status
            map_attribute "type", to: :type
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
