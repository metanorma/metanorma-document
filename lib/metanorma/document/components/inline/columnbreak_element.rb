# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Indication of a break in text rendered as columns (e.g. in
        # multilingual side-by-side rendering).
        class ColumnbreakElement < Lutaml::Model::Serializable
          xml do
            element "columnbreak"
          end
        end
      end
    end
  end
end
