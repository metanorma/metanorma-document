# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Lists
      # Unordered list block.
      class UnorderedList < Metanorma::BasicDocument::Lists::List
        xml do
          element "ul"
        end
      end
    end
  end
end
