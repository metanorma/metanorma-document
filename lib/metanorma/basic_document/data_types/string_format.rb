# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module DataTypes
      # The MIME type for a formatted string.
      class StringFormat < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "string-format"
          map_content to: :value
        end

        def self.values
          %w[text/plain text/html application/docbook+xml application/tei+xml
             text/x-asciidoc text/markdown application/x-metanorma+xml]
        end
      end
    end
  end
end
