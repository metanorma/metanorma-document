# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Ruby annotation giving the pronunciation of the annotated
        # text (standoc renaming of BasicDoc `pronunciation`). The
        # annotation value travels in the `value` attribute.
        class RubyPronunciationElement < Lutaml::Model::Serializable
          attribute :value, :string
          attribute :language, :string
          attribute :script, :string

          xml do
            element "ruby-pronunciation"
            map_attribute "value", to: :value
            map_attribute "language", to: :language
            map_attribute "script", to: :script
          end
        end
      end
    end
  end
end
