# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module IdElements
        # Anchor for cross-references which do not have scope over blocks or sections. Anchors within a block
        # under the BasicDocument model cannot span across a number of inline elements; bookmarks are intended
        # as point anchors. For that reason, the Review block has a starting reference and an optional ending
        # reference, which can be bookmarks as well as block or section references.
        class Bookmark < IdElement
          attribute :anchor, :string
          attribute :semx_id, :string

          xml do
            element "bookmark"
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
          end
        end
      end
    end
  end
end
