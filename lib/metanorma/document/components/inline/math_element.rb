module Metanorma
  module Document
    module Components
      module Inline
        class MathElement < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            element "math"
            map_all_content to: :content
          end
        end
      end
    end
  end
end
