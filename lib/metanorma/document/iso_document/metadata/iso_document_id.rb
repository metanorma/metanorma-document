# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Representation of the identifier for an ISO/IEC document, giving its individual semantic components.
  class IsoDocumentId < Core::Node
    include Core::Node::Custom

    register_element do
      # N-numbers assigned to the document by technical committees.
      nodes :tc_document_number, Integer

      # Numerical component uniquely identifying the document.
      attribute :project_number, Integer

      # Representation in the identifier of the document part, if this is a document part.
      attribute :part_number, Integer

      # Representation in the identifier of the document subpart, if this is a document subpart.
      # Only applicable to IEC documents.
      attribute :subpart_number, Integer

      # Representation in the identifier of the type of document amendment, if this is a document amendment.
      attribute :amendment_number, Integer

      # Representation in the identifier of the type of document technical corrigendum, if this is a
      # document technical corrigendum.
      attribute :corrigendum_number, Integer

      # Year of publication of the document in its current version or edition.
      attribute :originalyear, Integer
    end
  end
end; end; end
