# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Ruby annotation giving information other than pronunciation
        # of the annotated text (standoc renaming of BasicDoc
        # `annotation`). The annotation value travels in the `value`
        # attribute.
        class RubyAnnotationElement < Lutaml::Model::Serializable
          attribute :value, :string
          attribute :language, :string
          attribute :script, :string

          xml do
            element "ruby-annotation"
            map_attribute "value", to: :value
            map_attribute "language", to: :language
            map_attribute "script", to: :script
          end
        end
      end
    end
  end
end
