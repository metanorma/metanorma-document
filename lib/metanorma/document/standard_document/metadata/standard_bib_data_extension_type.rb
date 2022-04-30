# frozen_string_literal: true

require "metanorma/document/basic_document/bibdata/bib_data_extension_type"

module Metanorma; module Document; module StandardDocument
  # The extension point of the bibliographic description of a _StandardDocument_.
  class StandardBibDataExtensionType < BasicDocument::BibDataExtensionType
    register_element do
      # Classification of the _StandardDocument_ that is treated as a distinct series by the
      # standards defining organization, and that is rendered in a distinct manner.
      attribute :doctype, String

      # Standard abbreviation for the doctype value used by the standards defining organization.
      attribute :doctype_abbreviation, String

      # Subclass of the _StandardDocument_, that is treated or processed differently.
      attribute :subdoctype, String

      # Groups associated with the production of the standards document, typically within
      # a standards definition organization.
      node :editorial_group, EditorialGroupType

      # Classifications of the document contents taken from the International Classification of Standards.
      nodes :ics, IcsType

      # Representation of the identifier for the _StandardDocument_, giving its individual semantic
      # components.
      nodes :structuredidentifier, StructuredIdentifierType
    end
  end
end; end; end
