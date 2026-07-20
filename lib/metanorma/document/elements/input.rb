# frozen_string_literal: true

module Metanorma
  module Document
    module Elements
      # An `<input>` form field (text, checkbox, ...) as it appears inline
      # in form-bearing documents (e.g. OIML application forms). Lives in
      # the document layer so shared inline containers (ParagraphBlock,
      # TableCell, Inline::Vocabulary) can map it without referencing
      # higher model layers.
      class Input < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :name, :string
        attribute :value, :string
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

          map_attribute "id", to: :id
          map_attribute "name", to: :name
          map_attribute "value", to: :value
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
