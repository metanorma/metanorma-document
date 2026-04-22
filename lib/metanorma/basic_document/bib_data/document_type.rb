# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module BibData
      # Classifications of BasicDocuments.
      class DocumentType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "document-type"
          map_content to: :value
        end

        def self.values
          %w[document]
        end
      end
    end
  end
end
