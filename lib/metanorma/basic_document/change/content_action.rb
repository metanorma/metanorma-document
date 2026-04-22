# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Change
      # Specifies the kind of textual change to be undertaken.
      class ContentAction < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "content-action"
          map_content to: :value
        end

        def self.values
          %w[insert delete]
        end
      end
    end
  end
end
