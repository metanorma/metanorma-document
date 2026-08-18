# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Localisable rendering of a date in body content.
        class DateElement < Lutaml::Model::Serializable
          attribute :language, :string
          attribute :script, :string
          attribute :value, :string
          attribute :format, :string

          xml do
            element "date"
            map_attribute "language", to: :language
            map_attribute "script", to: :script
            map_attribute "value", to: :value
            map_attribute "format", to: :format
          end
        end
      end
    end
  end
end
