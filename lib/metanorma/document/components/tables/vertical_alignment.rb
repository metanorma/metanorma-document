# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        # Vertical alignment of the cell against the underlying table grid.
        class VerticalAlignment < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "vertical-alignmnent"
            map_content to: :value

            def self.values
              %w[top middle bottom baseline]
            end
          end
        end
      end
    end
  end
end
