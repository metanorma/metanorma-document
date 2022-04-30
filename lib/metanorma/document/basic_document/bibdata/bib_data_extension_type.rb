# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The extension point of the bibliographic description of a BasicDocument.
  class BibDataExtensionType < Core::Node
    include Core::Node::Custom

    register_element "doctype" do
      # Classification of the BasicDocument, indicating that it is to be rendered in a distinct manner.
      node :doctype, DocumentType
    end
  end
end; end; end
