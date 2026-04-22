# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # Extension point for extraneous elements that need to be added to standards document
      # from other schemas, e.g. UnitsML.
      class MiscContainer < Lutaml::Model::Serializable
        attribute :element, Object, collection: true

        attribute :semx_id, :string
        attribute :original_id, :string
        attribute :displayorder, :integer

        xml do
          element "misc-container"
          map_element "element", to: :element

          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
