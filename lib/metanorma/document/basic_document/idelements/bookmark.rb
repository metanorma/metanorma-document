# frozen_string_literal: true

require "metanorma/document/basic_document/idelements/id_element"

module Metanorma; module Document; module BasicDocument
  # Anchor for cross-references which do not have scope over blocks or sections. Anchors within a block
  # under the BasicDocument model cannot span across a number of inline elements; bookmarks are intended
  # as point anchors. For that reason, the Review block has a starting reference and an optional ending
  # reference, which can be bookmarks as well as block or section references.
  class Bookmark < IdElement
    register_element
  end
end; end; end
