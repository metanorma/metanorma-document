# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Representation of the identifier for a _StandardDocument_, giving its individual semantic
  # components.
  class StructuredIdentifierType < Core::Node
    include Core::Node::Custom

    register_element do
      # Representation in the identifier of the type of standard document.
      attribute :type, String

      # Representation in the identifier of the agency responsible for the standard document.
      nodes :agency, String

      # Representation in the identifier of the class of standard document (as a subclass of the document
      # type).
      attribute :class, String

      # Representation in the identifier of the (typically numeric) component uniquely identifying the
      # document
      # or standard. If a document includes parts or supplements, the docnumber identifies the document as
      # whole,
      # and not those document components.
      attribute :docnumber, String

      # Representation in the identifier of the document part, if this is a document part.
      attribute :partnumber, String

      # Representation in the identifier of the document edition, if this is a published document.
      attribute :edition, String

      # Representation in the identifier of the document version, which can include document drafts.
      attribute :version, String

      # Representation in the identifier of the type of document supplement, if this is a document
      # supplement.
      attribute :supplementtype, String

      # Representation in the identifier of the document supplement, if this is a document supplement.
      attribute :supplementnumber, String

      # Representation in the identifier of the year of publication or issuance of the document.
      attribute :year, String

      # Representation in the identifier of the language of the document.
      attribute :language, String
    end
  end
end; end; end
