# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The extension point of the bibliographic description of a BasicDocument.
  class BibDataExtensionType < Core::Node
    include Core::Node::Custom

    register_element do
      # Classification of the BasicDocument, indicating that it is to be rendered in a distinct manner.
      nodes :doctype, DocumentType
    end
  end
end; end; end
