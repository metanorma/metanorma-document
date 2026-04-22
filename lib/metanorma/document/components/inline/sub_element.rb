module Metanorma
  module Document
    module Components
      module Inline
        class SubElement < Lutaml::Model::Serializable
          attribute :content, :string
          xml do
            element "sub"
            map_content to: :content
          end
        end
      end
    end
  end
end
