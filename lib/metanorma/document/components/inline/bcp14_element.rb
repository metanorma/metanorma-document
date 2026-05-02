module Metanorma
  module Document
    module Components
      module Inline
        class Bcp14Element < Lutaml::Model::Serializable
          attribute :text, :string

          xml do
            element "bcp14"
            map_content to: :text
          end
        end
      end
    end
  end
end
