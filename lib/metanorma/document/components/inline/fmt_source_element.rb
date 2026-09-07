# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Rendered counterpart of a quote `<source>`: the formatted
        # attribution (author, source, modification) as a single semx
        # slice. Rendered to the exclusion of the semantic source
        # content when present.
        class FmtSourceElement < Lutaml::Model::Serializable
          include RenderedDisplay

          attribute :status, :string
          attribute :source_type, :string
          attribute :text, :string, collection: true
          attribute :semx, SemxElement, collection: true

          xml do
            element "fmt-source"
            mixed_content
            map_attribute "status", to: :status
            map_attribute "type", to: :source_type
            map_content to: :text
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
