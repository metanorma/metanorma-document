# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The publication or preparation status of a document.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Status has
      # singular stage/substage, its Stage lacks +language+, and there is no
      # stage-abbreviation element — fixtures carry multi-language stage
      # collections (read as .value/.language by the ISO renderer).
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
