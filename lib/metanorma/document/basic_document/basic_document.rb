# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Class modelling a basic document.
  class BasicDocument < Core::Node
    include Core::Node::Custom

    register_element do
      # A globally unique identifier for the document in an agreed identifier schema. The identifier is to
      # be used for tracking interactions with the document without depending on formal document registries;
      # it would be exemplified by a GUID, rather than a document registry identifier such as "`ISO 639`",
      # which belongs to `bibdata`.
      node :identifier, UniqueIdentifier

      # A bibliographic description, capturing bibliographic metadata about the document itself, including
      # authors, title, and date of production.
      node :bibdata, BibData

      # Hierarchically arranged units of textual content within the document.
      nodes :sections, BasicSection

      # A digital signature of the contribution.
      nodes :integrity_value, IntegrityValue
    end
  end
end; end; end
