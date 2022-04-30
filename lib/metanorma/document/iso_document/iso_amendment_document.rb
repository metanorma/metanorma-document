# frozen_string_literal: true

require "standard_document/standard_document"

module Metanorma; module Document; module IsoDocument
  # ISO Amendment or Technical Corrigenda document.
  class IsoAmendmentDocument < StandardDocument::StandardDocument
    register_element do
      # Version number of the schema used for this document.
      attribute :version, String

      # Bibliographic description of the document itself, expressed in the Relaton
      # model.
      node :bibdata, IsoBibliographicItem

      # Zero or more optional _preface_ sections.
      node :preface, IsoPreface

      # One or more _sections_. There are no annexes or bibliographies modelled for ISO Amendment or
      # Technical Corrigenda documents.
      nodes :sections, IsoAmendmentClause
    end
  end
end; end; end
