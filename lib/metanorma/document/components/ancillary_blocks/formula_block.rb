# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # Block containing a mathematical expression or other formulas.
        class FormulaBlock < Metanorma::Document::Components::Blocks::BasicBlockNoNotes
          # The content of the formula, as a mathematical expression.
          attribute :stem, Metanorma::Document::Components::TextElements::StemElement

          # The block should be excluded from any automatic numbering of blocks of this class in the document.
          attribute :unnumbered, :boolean

          # Define a subsequence for numbering of this block; e.g. if this block would be numbered
          # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
          # of the same class and with the same subsequence value, will be numbered consecutively
          # with the same number and in a subsequence: 7a, 7b, 7c etc.
          attribute :subsequence, :string

          # Indication that the formula is to be labelled as an Inequality, if inequalities are differentiated
          # from equations.
          attribute :inequality, :boolean

          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :autonum, :string
          attribute :displayorder, :integer

          # A definitions list defining any symbols used in the formula.
          attribute :dl, Metanorma::Document::Components::Lists::DefinitionList

          # The caption of the block.
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement

          # Key definitions for formula variables
          attribute :key, KeyElement

          # Presentation-specific elements
          attribute :fmt_stem, Metanorma::Document::Components::Inline::FmtStemElement
          attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement
          attribute :fmt_xref_label,
                    Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true
          attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true
          attribute :fmt_footnote_container, Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
                    collection: true

          attribute :json_type, :string

          def json_type
            "formula"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "stem", to: :stem
          end

          xml do
            element "formula"
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_attribute "autonum", to: :autonum
            map_attribute "displayorder", to: :displayorder
            map_element "stem", to: :stem
            map_attribute "unnumbered", to: :unnumbered
            map_attribute "subsequence", to: :subsequence
            map_attribute "inequality", to: :inequality
            map_element "dl", to: :dl
            map_element "name", to: :name
            map_element "key", to: :key
            map_element "fmt-stem", to: :fmt_stem
            map_element "fmt-name", to: :fmt_name
            map_element "fmt-xref-label", to: :fmt_xref_label
            map_element "p", to: :p
            map_element "fmt-footnote-container", to: :fmt_footnote_container
          end
        end
      end
    end
  end
end
