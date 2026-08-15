# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Presentation-layer rendering of an inline date.
        class FmtDateElement < Lutaml::Model::Serializable
          include RenderedDisplay

          attribute :id, :string
          attribute :text, :string, collection: true
          attribute :span, SpanElement, collection: true
          attribute :semx, SemxElement, collection: true

          xml do
            element "fmt-date"
            mixed_content
            map_attribute "id", to: :id
            map_content to: :text
            map_element "span", to: :span
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
