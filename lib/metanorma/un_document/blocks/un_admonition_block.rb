# frozen_string_literal: true

module Metanorma
  module UnDocument
    module Blocks
      # Admonition block of a UN document.
      # Corresponds to un.rng:
      #   AdmonitionType = danger | caution | warning | important |
      #                    "safety precautions"
      #   AdmonitionBody = tname?,
      #     ( paragraph-with-footnote | table | formula | ol | ul | dl |
      #       figure | quote | sourcecode | example | review )+,
      #     note*
      # The UN grammar widens the isodoc admonition body from paragraphs only
      # to most block types, with notes permitted after the body.
      # `uri` keeps the base model's element mapping (the current basicdoc
      # grammar declares it an attribute — a base-level divergence affecting
      # all flavors, left as-is here).
      class UnAdmonitionBlock < Metanorma::Document::Components::MultiParagraph::AdmonitionBlock
        # UN restricts AdmonitionType to five values.
        attribute :type, :string,
                  values: ["danger", "caution", "warning", "important",
                           "safety precautions"]

        attribute :tables,
                  Metanorma::Document::Components::Tables::TableBlock,
                  collection: true
        attribute :formulas,
                  Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                  collection: true
        attribute :ordered_lists,
                  Metanorma::Document::Components::Lists::OrderedList,
                  collection: true
        attribute :unordered_lists,
                  Metanorma::Document::Components::Lists::UnorderedList,
                  collection: true
        attribute :definition_lists,
                  Metanorma::Document::Components::Lists::DefinitionList,
                  collection: true
        attribute :figures,
                  Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                  collection: true
        attribute :quote_blocks,
                  Metanorma::Document::Components::MultiParagraph::QuoteBlock,
                  collection: true
        attribute :sourcecode_blocks,
                  Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
                  collection: true
        attribute :examples,
                  Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                  collection: true
        attribute :reviews,
                  Metanorma::Document::Components::MultiParagraph::ReviewBlock,
                  collection: true
        attribute :notes,
                  Metanorma::Document::Components::Blocks::NoteBlock,
                  collection: true

        xml do
          element "admonition"
          ordered

          map_attribute "id",         to: :id
          map_attribute "type",       to: :type
          map_attribute "class",      to: :block_class
          map_attribute "unnumbered", to: :unnumbered

          map_element "name",         to: :name
          map_element "fmt-name",     to: :fmt_name
          map_element "p",            to: :paragraphs
          map_element "table",        to: :tables
          map_element "formula",      to: :formulas
          map_element "ol",           to: :ordered_lists
          map_element "ul",           to: :unordered_lists
          map_element "dl",           to: :definition_lists
          map_element "figure",       to: :figures
          map_element "quote",        to: :quote_blocks
          map_element "sourcecode",   to: :sourcecode_blocks
          map_element "example",      to: :examples
          map_element "review",       to: :reviews
          map_element "note",         to: :notes
        end
      end
    end
  end
end
