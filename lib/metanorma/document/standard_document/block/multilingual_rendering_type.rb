# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # How a block element may be rendered in a multilingual document.
  class MultilingualRenderingType < Core::Node::Enum
    # Block is shared across all languages.
    COMMON = new("common")

    # Block spans all columns of text, and versions in different languages are displayed consecutively.
    ALL_COLUMNS = new("all-columns")

    # Block is to be aligned to the block occupying the same position in the document hierarchy.
    PARALLEL = new("parallel")

    # Block is to be aligned to all blocks sharing the same `tag` attribute as this block.
    TAG = new("tag")
  end
end; end; end
