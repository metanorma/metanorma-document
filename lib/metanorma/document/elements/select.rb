# frozen_string_literal: true

module Metanorma
  module Document
    module Elements
      class Select < Input
        attribute :multiple, :boolean
        attribute :size, :integer
        attribute :option, "Metanorma::Document::Elements::Option", collection: true

        xml do
          element "select"
          map_attribute "id", to: :id
          map_attribute "name", to: :name
          map_attribute "value", to: :value
          map_attribute "disabled", to: :disabled
          map_attribute "readonly", to: :readonly
          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
          map_attribute "multiple", to: :multiple
          map_attribute "size", to: :size
          map_element "option", to: :option
        end
      end
    end
  end
end
