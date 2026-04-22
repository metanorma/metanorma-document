# frozen_string_literal: true

module Metanorma
  module Collection
    # Root model for <metanorma-collection> XML.
    # Represents a collection of Metanorma documents bundled together,
    # with shared metadata, directives, and a manifest of entries.
    #
    # The collection root has no namespace (semantic) or xmlns="http://metanorma.org"
    # (presentation). Embedded <metanorma> documents inside doc-containers use
    # the standoc namespace (https://www.metanorma.org/ns/standoc).
    class Root < Lutaml::Model::Serializable
      attribute :bibdata, Metanorma::IsoDocument::Metadata::IsoBibliographicItem
      attribute :directive, Directive, collection: true
      attribute :entry, Entry
      attribute :format, :string, collection: true
      attribute :coverpage, :string
      attribute :doc_container, DocContainer, collection: true

      xml do
        element "metanorma-collection"
        map_element "bibdata", to: :bibdata
        map_element "directive", to: :directive
        map_element "entry", to: :entry
        map_element "format", to: :format
        map_element "coverpage", to: :coverpage
        map_element "doc-container", to: :doc_container
      end
    end
  end
end
