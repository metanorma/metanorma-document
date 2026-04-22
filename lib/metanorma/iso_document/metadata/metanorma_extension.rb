# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Container for metanorma-specific extensions (semantic-metadata,
      # presentation-metadata, UnitsML). Uses map_all_content to preserve
      # all child XML as raw string since these elements have complex
      # namespace-qualified structures.
      class MetanormaExtension < Lutaml::Model::Serializable
        attribute :content, :string

        xml do
          element "metanorma-extension"
          map_all_content to: :content
        end
      end
    end
  end
end
