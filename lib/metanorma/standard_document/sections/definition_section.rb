# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # Definition sections consist of one or more definition lists,
      # used to define symbols and abbreviations used in the remainder of
      # the document.
      #
      # Corresponds to isodoc.rnc:
      #   definitions = element definitions {
      #     Section-Attributes,
      #     ( (BasicBlock+) | (dl+) )?,
      #     definitions*
      #   }
      class DefinitionSection < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :anchor, :string
        attribute :type, :string
        attribute :number, :string
        attribute :obligation, :string
        attribute :inline_header, :string
        attribute :unnumbered, :string
        attribute :toc, :string
        attribute :class_attr, :string
        attribute :title,
                  Metanorma::Document::Components::Inline::TitleWithAnnotationElement

        # Block content
        attribute :paragraphs,
                  Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true
        attribute :unordered_lists,
                  Metanorma::Document::Components::Lists::UnorderedList,
                  collection: true
        attribute :tables,
                  Metanorma::Document::Components::Tables::TableBlock,
                  collection: true
        attribute :definition_lists,
                  Metanorma::Document::Components::Lists::DefinitionList,
                  collection: true
        attribute :examples,
                  Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true

        # Recursive definitions
        attribute :definitions, DefinitionSection, collection: true

        # Presentation-specific attributes
        attribute :semx_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer
        attribute :fmt_title,
                  Metanorma::Document::Components::Inline::FmtTitleElement
        attribute :fmt_xref_label,
                  Metanorma::Document::Components::Inline::FmtXrefLabelElement,
                  collection: true

        xml do
          element "definitions"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_content_section_attributes(self)

          map_element "title",         to: :title
          map_element "p",             to: :paragraphs
          map_element "ul",            to: :unordered_lists
          map_element "table",         to: :tables
          map_element "dl",            to: :definition_lists
          map_element "example",       to: :examples
          map_element "definitions",   to: :definitions
          map_element "fmt-title",     to: :fmt_title
          map_element "fmt-xref-label", to: :fmt_xref_label
        end
      end
    end
  end
end
