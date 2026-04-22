# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        # Inline reference to a paragraph or paragraphs, appearing as a footnote.
        class Footnote < ReferenceToIdWithParagraphElement
          attribute :type, :string

          xml do
            element "footnote"
            map_element "type", to: :type
          end
        end
      end
    end
  end
end
