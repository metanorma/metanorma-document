module Metanorma
  module Document
    module Components
      module Inline
        class AsciimathElement < Lutaml::Model::Serializable
          attribute :text, :string

          xml do
            element "asciimath"
            map_content to: :text
          end
        end
      end
    end
  end
end
