# frozen_string_literal: true

module Metanorma
  module UnDocument
    module Sections
      # Abstract of a UN document.
      # Corresponds to un.rng:
      #   abstract = element abstract { Basic-Section }
      #   Basic-Section = Basic-Section-Attributes, section-title?, BasicBlock+
      # Unlike the isodoc default (Content-Section), a UN abstract contains
      # no subsections, so no `clause` mapping is declared. Composed from the
      # shared mixins rather than inheriting ContentSection, because
      # lutaml-model deep-duplicates a parent's XML mappings into subclasses
      # (inheriting would keep the Content-Section `clause` mapping).
      class UnAbstractSection < Lutaml::Model::Serializable
        include Metanorma::StandardDocument::BlockAttributes
        include Metanorma::StandardDocument::PresentationAttributes

        attribute :id, :string
        attribute :obligation, :string
        attribute :title,
                  Metanorma::Document::Components::Inline::TitleWithAnnotationElement

        xml do
          element "abstract"
          ordered

          map_attribute "id",           to: :id
          map_attribute "obligation",   to: :obligation
          map_attribute "anchor",       to: :anchor
          map_attribute "semx-id",      to: :semx_id
          map_attribute "autonum",      to: :autonum
          map_attribute "displayorder", to: :displayorder

          map_element "title",                to: :title
          map_element "variant-title",        to: :variant_title
          map_element "fmt-title",            to: :fmt_title
          map_element "fmt-xref-label",       to: :fmt_xref_label

          Metanorma::StandardDocument::BlockXmlMapping.apply_block_mappings(self)

          map_element "fmt-annotation-start", to: :fmt_annotation_start
          map_element "fmt-annotation-end",   to: :fmt_annotation_end
        end
      end
    end
  end
end
