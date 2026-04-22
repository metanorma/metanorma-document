# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Paragraphs
      # The alignment of the paragraph against the margins of the document.
      class TextAlignment < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "text-alignment"
          map_content to: :value
        end

        def self.values
          %w[left center right justified]
        end
      end
    end
  end
end
