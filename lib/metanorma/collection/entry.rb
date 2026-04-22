# frozen_string_literal: true

module Metanorma
  module Collection
    # An entry in a metanorma-collection manifest.
    # Entries are recursive — a top-level entry can contain nested entries,
    # each representing a document in the collection.
    class Entry < Lutaml::Model::Serializable
      attribute :index, :string
      attribute :target, :string
      attribute :fileref, :string
      attribute :identifier, :string
      attribute :type, :string
      attribute :title, :string
      attribute :format, :string, collection: true
      attribute :bibdata, Metanorma::IsoDocument::Metadata::IsoBibliographicItem
      attribute :entry, Entry, collection: true

      xml do
        element "entry"
        map_attribute "index", to: :index
        map_attribute "target", to: :target
        map_attribute "fileref", to: :fileref
        map_element "identifier", to: :identifier
        map_element "type", to: :type
        map_element "title", to: :title
        map_element "format", to: :format
        map_element "bibdata", to: :bibdata
        map_element "entry", to: :entry
      end
    end
  end
end
