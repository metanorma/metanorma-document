# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Type of indicator of a location or extent within a bibliographic item.
      #
      # When the value `whole` or `title` is used, the corresponding `BibItemLocality`
      # attribute `identifier` should be empty.
      class SpecificLocalityType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "specific-locality-type"
          map_content to: :value
        end

        def self.values
          %w[section clause part paragraph chapter page whole table annex figure
             note list example volume issue time anchor title line localityString]
        end
      end
    end
  end
end
