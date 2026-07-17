# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Rendered counterpart of `<stem>`. Produced by presentation XML
        # transformation. Wraps a `<semx>` carrying the locale-rendered
        # form of the math (e.g. decimal commas, thousands separators).
        class FmtStemElement < Lutaml::Model::Serializable
          include RenderedDisplay

          attribute :stem_type, :string
          attribute :text, :string, collection: true
          attribute :semx, SemxElement, collection: true

          xml do
            element "fmt-stem"
            mixed_content
            map_attribute "type", to: :stem_type
            map_content to: :text
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
