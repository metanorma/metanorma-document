# frozen_string_literal: true

module Metanorma
  module BasicDocument
    # Underlined text. Corresponds to HTML 4 `u`.
    class UnderlineElement < Metanorma::BasicDocument::TextElements::TextElement
      xml do
        element "underline"
      end
    end
  end
end
