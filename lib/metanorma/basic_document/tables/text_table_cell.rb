# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Tables
      # Table cells composed of inline elements, and therefore corresponding to a single block.
      class TextTableCell < Metanorma::BasicDocument::Tables::TableCell
        attribute :content,
                  Metanorma::BasicDocument::TextElements::TextElement, collection: true

        xml do
          element "td"
          map_element "content", to: :content
        end
      end
    end
  end
end
