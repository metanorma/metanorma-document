# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The publication or preparation status of a document.
      class DocumentStatus < Lutaml::Model::Serializable
        attribute :stage, Metanorma::Document::Components::DataTypes::FormattedString,
                  collection: true
        attribute :stage_abbreviation, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :substage, Metanorma::Document::Components::DataTypes::FormattedString,
                  collection: true
        attribute :substage_abbreviation, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :iteration, Metanorma::Document::Components::DataTypes::LocalizedString

        xml do
          map_element "stage", to: :stage
          map_element "stage-abbreviation", to: :stage_abbreviation
          map_element "substage", to: :substage
          map_element "substage-abbreviation", to: :substage_abbreviation
          map_element "iteration", to: :iteration
        end
      end
    end
  end
end
