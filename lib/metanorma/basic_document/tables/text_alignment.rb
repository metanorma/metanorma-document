# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Tables
      # Horizontal textual alignment of the cell against the underlying table grid.
      class TextAlignment < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "text-alignmnent"
          map_content to: :value
        end

        def self.values
          %w[left center right]
        end
      end
    end
  end
end
