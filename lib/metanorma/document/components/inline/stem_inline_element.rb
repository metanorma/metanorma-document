module Metanorma
  module Document
    module Components
      module Inline
        class StemInlineElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :block, :string
          attribute :stem_type, :string
          attribute :asciimath, AsciimathElement, collection: true
          attribute :math, MathElement, collection: true

          xml do
            element "stem"
            map_attribute "id", to: :id
            map_attribute "block", to: :block
            map_attribute "type", to: :stem_type
            map_element "asciimath", to: :asciimath
            map_element "math", to: :math
          end
        end
      end
    end
  end
end
