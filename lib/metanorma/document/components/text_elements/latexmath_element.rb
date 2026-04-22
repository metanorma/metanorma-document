# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Mathematical text formatted in LaTeX.
        class LatexmathElement < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "latexmath"
            map_content to: :value
          end
        end
      end
    end
  end
end
