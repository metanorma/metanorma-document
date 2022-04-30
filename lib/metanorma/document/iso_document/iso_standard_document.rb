# frozen_string_literal: true

require "metanorma/document/standard_document/standard_document"

module Metanorma; module Document; module IsoDocument
  # ISO Standards document.
  class IsoStandardDocument < StandardDocument::StandardDocument
    register_element do
      # Version number of the schema used for this standards document.
      attribute :version, String

      # Bibliographic description of the document itself, expressed in the Relaton
      # model.
      node :bibdata, IsoBibliographicItem

      # Citations for sources of term definitions.
      nodes :term_sources, BasicDocument::Citation

      # Zero or more optional _preface_ sections.
      node :preface, IsoPreface

      # One or more _sections_.
      node :sections, IsoSections

      # Zero or more _annexes_.
      nodes :annex, IsoAnnexSection

      # Zero to two _bibliographies_.
      nodes :bibliography, StandardDocument::StandardReferencesSection

      # Index of a standards document.
      node :indexsect, BasicDocument::BasicSection
    end
  end
end; end; end
