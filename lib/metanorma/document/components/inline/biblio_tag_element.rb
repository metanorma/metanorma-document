module Metanorma
  module Document
    module Components
      module Inline
        class BiblioTagElement < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :span, SpanElement, collection: true
          attribute :fn, FnElement, collection: true
          attribute :tab, TabElement, collection: true

          xml do
            element "biblio-tag"
            mixed_content
            map_content to: :text
            map_element "span", to: :span
            map_element "fn", to: :fn
            map_element "tab", to: :tab
          end
        end
      end
    end
  end
end
