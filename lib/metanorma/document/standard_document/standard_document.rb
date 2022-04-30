# frozen_string_literal: true

require "basic_document/basic_document"

module Metanorma; module Document; module StandardDocument
  # The _StandardDocument_ model is used to represent a standardization
  # document.
  #
  # Typically, a standardization document contains at least the
  # following data elements:
  #
  # * Metadata information;
  # * Clauses and subclauses;
  # * Bibliographies;
  # * Annexes if applicable.
  #
  # The exact component requirements of a standardization document
  # can differ widely from one standardization body to the next.
  # Specialization is necessary to adopt the `StandardDocument`
  # model for such standardization bodies.
  #
  # The _StandardDocument_ model extends the _BasicDocument_
  # modelling of the document by requiring specific types
  # of sections.
  class StandardDocument < BasicDocument::BasicDocument
    register_element do
      # Bibliographic description of the document itself, expressed in the Relaton
      # model.
      node :bibdata, StandardBibData

      # Extension point for extraneous elements that need to be added to standards document
      # from other schemas, e.g. UnitsML.
      node :misc, MiscContainer

      # An optional _boilerplate_ section, intended to appear at the
      # front of the document. It consists of content addressing
      # _copyright_, _license_, _legal_, and _feedback_ concerns.
      node :boilerplate, BoilerplateType

      # Zero or more optional _preface_ sections.
      nodes :preface, StandardHierarchicalSection

      # One or more _sections_.
      nodes :sections, StandardHierarchicalSection

      # Zero or more _annexes_.
      nodes :annex, StandardHierarchicalSection

      # Zero or more _bibliographies_.
      nodes :bibliography, StandardReferencesSection

      # Index of a standards document.
      nodes :indexsect, StandardHierarchicalSection

      # Type of standards document representation given in this class instance.
      # Set to "standard" for all standards documents.
      attribute :type, StandardDocumentType

      # Version number of the schema used for this standards document.
      attribute :version, String
    end
  end
end; end; end
