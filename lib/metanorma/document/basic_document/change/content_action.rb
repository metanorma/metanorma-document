# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Specifies the kind of textual change to be undertaken.
  class ContentAction < Core::Node::Enum
    # Text is to be added.
    INSERT = new("insert")

    # Text is to be removed.
    DELETE = new("delete")
  end
end; end; end
