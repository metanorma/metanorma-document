# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module UpdateUnits
        # Period during which the unit's current text is in force.
        class Validity < Lutaml::Model::Serializable
          attribute :begins, :date
          attribute :ends, :date

          xml do
            element "validity"
            map_element "begins", to: :begins
            map_element "ends", to: :ends
          end

          key_value do
            map "begins", to: :begins
            map "ends", to: :ends
          end
        end
      end
    end
  end
end
