# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Elements
      # Indication of text added through editorial intervention.
      class Input < Metanorma::StandardDocument::Elements::FormInput
        attribute :type, :string
        attribute :checked, :boolean
        attribute :disabled, :boolean
        attribute :readonly, :boolean
        attribute :maxlength, :integer
        attribute :minlength, :integer

        attribute :semx_id, :string
        attribute :original_id, :string

        xml do
          element "input"
          map_attribute "type", to: :type
          map_attribute "checked", to: :checked
          map_attribute "disabled", to: :disabled
          map_attribute "readonly", to: :readonly
          map_attribute "maxlength", to: :maxlength
          map_attribute "minlength", to: :minlength

          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
        end
      end
    end
  end
end
