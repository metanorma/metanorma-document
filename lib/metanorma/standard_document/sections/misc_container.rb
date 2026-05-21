# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # Extension point for extraneous elements that need to be added to standards document
      # from other schemas, e.g. UnitsML.
      #
      # Content is stored as raw XML text since the children come from external
      # vocabularies not defined in the metanorma schema.
      class MiscContainer < Lutaml::Model::Serializable
        attribute :content, :string

        attribute :semx_id, :string
        attribute :original_id, :string
        attribute :displayorder, :integer

        xml do
          element "misc-container"
          map_content to: :content

          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
