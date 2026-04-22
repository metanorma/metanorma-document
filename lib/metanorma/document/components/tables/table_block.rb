# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        # Column element within colgroup.
        class ColElement < Lutaml::Model::Serializable
          attribute :width, :string

          xml do
            element "col"
            map_attribute "width", to: :width
          end
        end

        # Column group element for table column width specifications.
        class ColGroupElement < Lutaml::Model::Serializable
          attribute :col, ColElement, collection: true

          xml do
            element "colgroup"
            map_element "col", to: :col
          end
        end

        # Tabular arrangement of text
        class TableBlock < Metanorma::Document::Components::Blocks::BasicBlock
          attribute :id, :string
          attribute :anchor, :string
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement
          attribute :unnumbered, :boolean
          attribute :subsequence, :string
          attribute :alt, :string
          attribute :summary, :string
          attribute :uri, :string
          attribute :semx_id, :string
          attribute :autonum, :string
          attribute :displayorder, :integer
          attribute :thead, TableHeadSection
          attribute :tbody, TableBodySection
          attribute :tfoot, TableFootSection
          attribute :note, Metanorma::Document::Components::Blocks::NoteBlock,
                    collection: true
          attribute :dl, Metanorma::Document::Components::Lists::DefinitionList
          attribute :key, Metanorma::Document::Components::AncillaryBlocks::KeyElement
          attribute :colgroup, ColGroupElement

          # Presentation-specific elements
          attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement
          attribute :fmt_xref_label,
                    Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true
          attribute :fmt_footnote_container, Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
                    collection: true

          attribute :width, :string
          attribute :json_type, :string

          def json_type
            "table"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "anchor", to: :anchor
            map "name", to: :name
          end

          xml do
            element "table"
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_element "name", to: :name
            map_attribute "unnumbered", to: :unnumbered
            map_attribute "subsequence", to: :subsequence
            map_attribute "alt", to: :alt
            map_attribute "summary", to: :summary
            map_attribute "uri", to: :uri
            map_attribute "width", to: :width
            map_attribute "semx-id", to: :semx_id
            map_attribute "autonum", to: :autonum
            map_attribute "displayorder", to: :displayorder
            map_element "thead", to: :thead
            map_element "tbody", to: :tbody
            map_element "tfoot", to: :tfoot
            map_element "note", to: :note
            map_element "dl", to: :dl
            map_element "colgroup", to: :colgroup
            map_element "key", to: :key
            map_element "fmt-name", to: :fmt_name
            map_element "fmt-xref-label", to: :fmt_xref_label
            map_element "fmt-footnote-container", to: :fmt_footnote_container
          end
        end
      end
    end
  end
end
