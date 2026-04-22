# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        # Definition used to constitute a definition list.
        class Definition < Lutaml::Model::Serializable
          attribute :item, "Metanorma::Document::Components::TextElements::TextElement",
                    collection: true
          attribute :definition,
                    "Metanorma::Document::Components::Paragraphs::ParagraphWithFootnote", collection: true
          attribute :p,
                    "Metanorma::Document::Components::Paragraphs::ParagraphBlock", collection: true
          attribute :ol, OrderedList, collection: true
          attribute :ul, UnorderedList, collection: true
          attribute :fmt_fn_body, "Metanorma::Document::Components::Inline::FmtFnBodyElement"

          xml do
            element "dd"
            map_element "item", to: :item
            map_element "definition", to: :definition
            map_element "p", to: :p
            map_element "ol", to: :ol
            map_element "ul", to: :ul
            map_element "fmt-fn-body", to: :fmt_fn_body
          end
        end
      end
    end
  end
end
