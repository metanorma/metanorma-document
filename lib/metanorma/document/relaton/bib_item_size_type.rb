# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Type of size of a bibliographic item. In principle, this is open-ended, but
  # there are recommended values for standard size measures.
  class BibItemSizeType < Core::Node::Enum
    # Page count.
    PAGE = new("page")

    # Volume count.
    VOLUME = new("volume")

    # Time duration (expressed as ISO 8601 duration value).
    TIME = new("time")

    # Data size (includes unit, e.g. "6.8 GB").
    DATA = new("data")

    # A free-form text string.
    VALUE = new("value")
  end
end; end; end
