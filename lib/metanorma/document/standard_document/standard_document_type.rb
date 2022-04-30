# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Type of standards document representation.
  class StandardDocumentType < Core::Node::Enum
    # Standards document representation representing the semantics of the document.
    SEMANTIC = new("semantic")

    # Standards document representation denormalised to prioritise rendering concerns for the document.
    PRESENTATION = new("presentation")
  end
end; end; end
