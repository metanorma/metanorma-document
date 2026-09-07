# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Rendered counterpart of an inline `<date>`: the i18n'd
        # rendering of a value/format-marked date, appearing inside the
        # semantic date element.
        class FmtDateInlineElement < Lutaml::Model::Serializable
          include RenderedDisplay

          attribute :text, :string, collection: true
          attribute :semx, SemxElement, collection: true

          xml do
            element "fmt-date-inline"
            mixed_content
            map_content to: :text
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
