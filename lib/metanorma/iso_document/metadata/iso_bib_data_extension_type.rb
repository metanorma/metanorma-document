# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      # Extension point for bibliographical definitions of ISO/IEC documents.
      # Document type element with language attribute.
      class DoctypeElement < Lutaml::Model::Serializable
        attribute :language, :string
        attribute :abbreviation, :string
        attribute :value, :string

        xml do
          element "doctype"
          map_attribute "language", to: :language, render_empty: true
          map_attribute "abbreviation", to: :abbreviation
          map_content to: :value
        end
      end

      # Stage name element with abbreviation attribute.
      class StagenameElement < Lutaml::Model::Serializable
        attribute :abbreviation, :string
        attribute :value, :string

        xml do
          element "stagename"
          map_attribute "abbreviation", to: :abbreviation
          map_content to: :value
        end
      end

      class IsoBibDataExtensionType < Lutaml::Model::Serializable
        # The document is a horizontal standard.
        attribute :horizontal, :boolean

        # Editorial groups associated with the production of the document.
        attribute :editorial_group, IsoProjectGroup

        # Name of the publication stage of the document.
        attribute :stage_name, :string

        # Category of IEC Standard applicable.
        attribute :category, :string

        # Type of document being updated by this document, if it is an amendment or technical corrigendum.
        attribute :updates_document_type, :string
        attribute :semx_id, :string

        # Document type (e.g. "international-standard").
        attribute :doctype, DoctypeElement, collection: true

        # Document flavor (e.g. "iso").
        attribute :flavor, :string

        # ICS classification codes.
        attribute :ics, Ics, collection: true

        # Structured identifier (project number, part).
        attribute :structuredidentifier, StructuredIdentifier

        # Name of the publication stage.
        attribute :stagename, StagenameElement

        # Sub-document type.
        attribute :subdoctype, :string

        xml do
          element "ext"
          map_attribute "horizontal", to: :horizontal
          map_element "editorial-group", to: :editorial_group
          map_attribute "stage-name", to: :stage_name
          map_attribute "category", to: :category
          map_attribute "semx-id", to: :semx_id
          map_element "doctype", to: :doctype
          map_element "flavor", to: :flavor
          map_element "ics", to: :ics
          map_element "structuredidentifier", to: :structuredidentifier
          map_element "stagename", to: :stagename
          map_element "updates-document-type", to: :updates_document_type
          map_element "subdoctype", to: :subdoctype
        end
      end
    end
  end
end
