# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Lists
      # Definition used to constitute a definition list.
      class Definition < Lutaml::Model::Serializable
        attribute :item, Metanorma::BasicDocument::TextElements::TextElement,
                  collection: true
        attribute :definition,
                  Metanorma::BasicDocument::Paragraphs::ParagraphWithFootnote, collection: true

        xml do
          element "dd"
          map_element "item", to: :item
          map_element "definition", to: :definition
        end
      end
    end
  end
end
