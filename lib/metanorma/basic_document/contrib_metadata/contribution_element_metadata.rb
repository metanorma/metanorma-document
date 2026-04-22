# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ContribMetadata
      # Container encoding the contribution made by a party towards a particular element in the document
      class ContributionElementMetadata < Lutaml::Model::Serializable
        attribute :date_time,
                  :string
        attribute :contributor, Metanorma::Document::Relaton::Contributor
        attribute :integrity_value, :string, collection: true

        xml do
          element "contribution-element-metadata"
          map_attribute "date-time", to: :date_time
          map_element "contributor", to: :contributor
          map_element "integrity-value", to: :integrity_value
        end
      end
    end
  end
end
