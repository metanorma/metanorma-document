# frozen_string_literal: true

require "standard_document/metadata/standard_bib_data_extension_type"

module Metanorma; module Document; module IsoDocument
  # Extension point for bibliographical definitions of ISO/IEC documents.
  class IsoBibDataExtensionType < StandardDocument::StandardBibDataExtensionType
    register_element do
      # The document is a horizontal standard.
      attribute :horizontal, TrueClass

      # Editorial groups associated with the production of the document.
      node :editorial_group, IsoProjectGroup

      # Name of the publication stage of the document.
      attribute :stage_name, String

      # Category of IEC Standard applicable.
      attribute :category, IecDocumentCategory

      # Type of document being updated by this document, if it is an amendment or technical corrigendum.
      attribute :updates_document_type, BasicDocument::DocumentType
    end
  end
end; end; end
