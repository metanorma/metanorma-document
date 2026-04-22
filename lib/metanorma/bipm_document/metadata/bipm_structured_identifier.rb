# frozen_string_literal: true

module Metanorma
  module BipmDocument
    module Metadata
      # Structured identifier for BIPM documents (docnumber only).
      class BipmStructuredIdentifier < Lutaml::Model::Serializable
        attribute :docnumber, :string
        attribute :part, :string
        attribute :appendix, :string

        xml do
          element "structuredidentifier"
          map_element "docnumber", to: :docnumber
          map_element "part", to: :part
          map_element "appendix", to: :appendix
        end
      end
    end
  end
end
