module Metanorma
  module Document
    module Components
      module Inline
        class SmallCapElement < Lutaml::Model::Serializable
          attribute :text, :string

          xml do
            element "smallcap"
            map_content to: :text
          end
        end
      end
    end
  end
end
