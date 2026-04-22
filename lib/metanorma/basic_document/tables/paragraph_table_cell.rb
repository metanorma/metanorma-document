# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Tables
      # Table cells composed of multiple paragraphs.
      class ParagraphTableCell < Metanorma::BasicDocument::Tables::TableCell
        attribute :content,
                  Metanorma::BasicDocument::Paragraphs::ParagraphWithFootnote, collection: true

        xml do
          element "paragraph-table-cell"
          map_element "content", to: :content
        end
      end
    end
  end
end
