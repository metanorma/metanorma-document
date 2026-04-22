# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module BibData
        # Classifications of BasicDocuments.
        class DocumentType < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "document-type"
            map_content to: :value

            def self.values
              %w[document]
            end
          end
        end
      end
    end
  end
end
