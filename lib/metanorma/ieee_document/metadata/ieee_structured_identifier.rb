# frozen_string_literal: true

module Metanorma
  module IeeeDocument
    module Metadata
      # Structured identifier for IEEE documents (docnumber, agency, class, version, year).
      class IeeeStructuredIdentifier < Lutaml::Model::Serializable
        attribute :docnumber, :string
        attribute :agency, :string
        attribute :klass, :string
        attribute :version, :string
        attribute :year, :string

        xml do
          element "structuredidentifier"
          map_element "docnumber", to: :docnumber
          map_element "agency", to: :agency
          map_element "class", to: :klass
          map_element "version", to: :version
          map_element "year", to: :year
        end
      end
    end
  end
end
