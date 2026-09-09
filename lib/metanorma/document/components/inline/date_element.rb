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
          attribute :fmt_date_inline,
                    "Metanorma::Document::Components::Inline::FmtDateInlineElement",
                    collection: true

          xml do
            element "date"
            map_attribute "language", to: :language
            map_attribute "script", to: :script
            map_attribute "value", to: :value
            map_attribute "format", to: :format
            map_element "fmt-date-inline", to: :fmt_date_inline
          end
        end
      end
    end
  end
end
