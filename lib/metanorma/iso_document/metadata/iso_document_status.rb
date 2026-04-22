# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Publication status of an ISO/IEC document.
      # Stage element in presentation XML: <stage abbreviation="..." language="..." type="...">value</stage>
      class StageElement < Lutaml::Model::Serializable
        attribute :abbreviation, :string
        attribute :language, :string
        attribute :type, :string
        attribute :value, :string, collection: true
        attribute :br, Metanorma::Document::Components::Inline::BrElement,
                  collection: true

        xml do
          element "stage"
          mixed_content
          map_attribute "abbreviation", to: :abbreviation
          map_attribute "language", to: :language, render_empty: true
          map_attribute "type", to: :type
          map_content to: :value
          map_element "br", to: :br
        end
      end

      class IsoDocumentStatus < Lutaml::Model::Serializable
        # Publication stage of the ISO/IEC document, expressed as an International Harmonized Stage Code.
        attribute :stage, StageElement, collection: true

        # Standard abbreviation of the publication stage.
        attribute :stage_abbreviation, :string

        # Substage code for the ISO/IEC document.
        attribute :substage, IsoDocumentSubstageCodes

        # Standard abbreviation of the publication substage.
        attribute :substage_abbreviation, :string

        # Number of the iteration of the publication stage that the document is in.
        attribute :iteration, :integer
        attribute :semx_id, :string

        xml do
          element "status"
          map_element "stage", to: :stage
          map_element "stage-abbreviation", to: :stage_abbreviation
          map_element "substage", to: :substage
          map_element "substage-abbreviation", to: :substage_abbreviation
          map_element "iteration", to: :iteration
          map_attribute "semx-id", to: :semx_id
        end
      end
    end
  end
end
