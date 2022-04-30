# frozen_string_literal: true

require "basic_document/bibdata/bibliographic_item"

module Metanorma; module Document; module IsoDocument
  # The bibliographical description of an ISO/IEC document.
  class IsoBibliographicItem < BasicDocument::BibliographicItem
    register_element do
      # Identifier of the document.
      node :doc_identifier, IsoDocumentId

      # Title of the document.
      node :title, IsoLocalizedTitle

      # Type of the document.
      attribute :type, IsoDocumentType

      # Publication status of the document.
      node :status, IsoDocumentStatus

      # URIs associated with the document.
      nodes :source, BasicObject # But actually: TypeUri

      # Abstract of the document.
      nodes :abstract, BasicDocument::FormattedString

      # Extension point of the bibliographical description.
      node :ext, IsoBibDataExtensionType
    end
  end
end; end; end
