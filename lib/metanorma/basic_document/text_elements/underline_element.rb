# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      class UnderlineElement < Metanorma::BasicDocument::TextElements::TextElement
        xml do
          element "underline"
        end
      end
    end
  end
end
