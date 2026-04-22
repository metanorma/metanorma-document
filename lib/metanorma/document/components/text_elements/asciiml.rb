# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Mathematical text formatted in AsciiMath.
        class Asciiml < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "asciimath"
            map_content to: :value
          end
        end
      end
    end
  end
end
