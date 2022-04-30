# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The bibliographic description of a BasicDocument.
  # BibData differs from BibliographicItem by making `title` and `copyright` mandatory.
  class BibData < Core::Node
    include Core::Node::Custom

    register_element "ext" do
      # The extension point of the bibliographic description of a BasicDocument.
      node :ext, BibDataExtensionType
    end
  end
end; end; end
