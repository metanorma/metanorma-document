# frozen_string_literal: true

module Metanorma
  module Document
    module Elements
      class Option < Lutaml::Model::Serializable
        attribute :disabled, :boolean
        attribute :selected, :boolean
        attribute :value, :string
        attribute :content, :string

        xml do
          element "option"
          map_attribute "disabled", to: :disabled
          map_attribute "selected", to: :selected
          map_attribute "value", to: :value
          map_content to: :content
        end
      end
    end
  end
end
