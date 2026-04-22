# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        # Table cells composed of multiple paragraphs.
        class ParagraphTableCell < TableCell
          attribute :content, Metanorma::Document::Components::Paragraphs::ParagraphWithFootnote,
                    collection: true

          xml do
            element "paragraph-table-cell"
            map_element "content", to: :content
          end
        end
      end
    end
  end
end
