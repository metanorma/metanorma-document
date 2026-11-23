# frozen_string_literal: true

require_relative "../inline/fmt_ladl_label_data"

module Metanorma
  module Document
    module Components
      module Blocks
        # Base class of blocks for a BasicDocument, omitting notes.
        class BasicBlockNoNotes < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :contrib_metadata, Metanorma::Document::Components::ContribMetadata::ContributionElementMetadata,
                    collection: true

          attribute :fmt_ladl_label_data, Metanorma::Document::Components::Inline::FmtLadlLabelData

          attribute :hidden, :boolean

          xml do
            map_attribute "hidden", to: :hidden
            map_element "fmt-ladl-label-data", to: :fmt_ladl_label_data
            element "basic-block-no-notes"
            map_attribute "id", to: :id
            map_element "contrib-metadata", to: :contrib_metadata
          end
        end
      end
    end
  end
end
