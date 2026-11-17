# frozen_string_literal: true

module Metanorma
  module Document
    module Elements
      class Textarea < Input
        attribute :rows, :integer
        attribute :cols, :integer

        xml do
          element "textarea"
          map_attribute "id", to: :id
          map_attribute "name", to: :name
          map_attribute "value", to: :value
          map_attribute "disabled", to: :disabled
          map_attribute "readonly", to: :readonly
          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
          map_attribute "rows", to: :rows
          map_attribute "cols", to: :cols
        end
      end
    end
  end
end
