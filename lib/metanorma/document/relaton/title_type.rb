# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Type of title given to a bibliographic item.
  class TitleType < Core::Node::Enum
    # Alternate title for the item.
    ALTERNATIVE = new("alternative")

    # The original title of the item. Includes the source language title of a translated item.
    ORIGINAL = new("original")

    # A title that has become prevalent but has never been the official or intended title
    # of the item.
    UNOFFICIAL = new("unofficial")

    # Subsidiary title of the item.
    SUBTITLE = new("subtitle")

    # The default title of the item, privileged in citation.
    MAIN = new("main")
  end
end; end; end
