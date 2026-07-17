# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Marker module for `fmt-*` element classes — the rendered
        # counterparts of semantic elements. Including this module marks
        # a class as a presentation-layer sibling (e.g. `FmtStemElement`
        # is the rendered counterpart of `StemInlineElement`).
        #
        # Used by `SemanticContent#each_semantic_content` to filter out
        # rendered siblings so consumers iterating semantic content don't
        # see both forms of the same logical content.
        #
        # Adding a new `fmt-*` class means one `include RenderedDisplay`
        # line — no edits to the filtering logic.
        module RenderedDisplay
        end
      end
    end
  end
end
