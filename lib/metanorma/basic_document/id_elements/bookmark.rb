# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module IdElements
      # Anchor for cross-references which do not have scope over blocks or sections. Anchors within a block
      # under the BasicDocument model cannot span across a number of inline elements; bookmarks are intended
      # as point anchors. For that reason, the Review block has a starting reference and an optional ending
      # reference, which can be bookmarks as well as block or section references.
      class Bookmark < Metanorma::BasicDocument::IdElements::IdElement
        xml do
          element "bookmark"
        end
      end
    end
  end
end
