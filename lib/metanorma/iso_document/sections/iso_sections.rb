# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Main body of ISO/IEC document.
      class IsoSections < Lutaml::Model::Serializable
        # Notes applicable to the entire document (e.g. footnotes on title).
        attribute :note,
                  Metanorma::Document::Components::Blocks::NoteBlock,
                  collection: true

        # Admonitions applicable to the entire document (appearing before the initial clause).
        attribute :admonition,
                  Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                  collection: true

        # Terms & Definitions clause.
        attribute :terms,
                  IsoTermsSection

        # Symbols & Abbreviated Terms clause.
        attribute :definitions,
                  Metanorma::StandardDocument::Sections::DefinitionSection

        # Normal Clauses.
        attribute :clause,
                  IsoClauseSection,
                  collection: true

        # References section (can appear inside <sections> in presentation XML).
        attribute :references,
                  Metanorma::StandardDocument::Sections::StandardReferencesSection,
                  collection: true

        # Initial paragraphs (document title repeated at start of sections in some flavours).
        attribute :p,
                  Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true

        # Presentation-specific attributes
        attribute :semx_id, :string
        attribute :displayorder, :integer

        xml do
          element "sections"
          ordered
          map_element "note", to: :note
          map_element "admonition", to: :admonition
          map_element "terms", to: :terms
          map_element "definitions", to: :definitions
          map_element "clause", to: :clause
          map_element "references", to: :references
          map_element "p", to: :p
          map_attribute "semx-id", to: :semx_id
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
