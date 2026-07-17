# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Shared vocabulary of inline child elements that may appear in any
        # general-purpose inline-content container. Including this module
        # in a `Lutaml::Model::Serializable` subclass declares every inline
        # element type as a collection attribute, so that no inline child
        # encountered during parsing is silently dropped.
        #
        # Use together with `VocabularyXmlMapping.apply_inline_mappings`
        # inside the class's `xml do ... end` block.
        #
        # Restricted child sets (e.g. `XrefElement` with only `<location>`
        # children) intentionally do NOT include this module — they have
        # semantic reasons to exclude the general vocabulary.
        module Vocabulary
          def self.included(base)
            declare_text_attributes_on(base)
            declare_formatting_attributes_on(base)
            declare_cross_reference_attributes_on(base)
            declare_structural_attributes_on(base)
            declare_rendered_display_attributes_on(base)
          end

          class << self
            def declare_text_attributes_on(base)
              base.attribute :text, :string, collection: true
              base.attribute :semx,
                             Metanorma::Document::Components::Inline::SemxElement,
                             collection: true
            end

            def declare_formatting_attributes_on(base)
              base.attribute :em,
                             Metanorma::Document::Components::Inline::EmRawElement,
                             collection: true
              base.attribute :strong,
                             Metanorma::Document::Components::Inline::StrongRawElement,
                             collection: true
              base.attribute :sub,
                             Metanorma::Document::Components::Inline::SubElement,
                             collection: true
              base.attribute :sup,
                             Metanorma::Document::Components::Inline::SupElement,
                             collection: true
              base.attribute :tt,
                             Metanorma::Document::Components::Inline::TtElement,
                             collection: true
              base.attribute :underline,
                             Metanorma::Document::Components::TextElements::UnderlineElement,
                             collection: true
              base.attribute :strike,
                             Metanorma::Document::Components::TextElements::StrikeElement,
                             collection: true
              base.attribute :smallcap,
                             Metanorma::Document::Components::Inline::SmallCapElement,
                             collection: true
            end

            def declare_cross_reference_attributes_on(base)
              base.attribute :xref,
                             Metanorma::Document::Components::Inline::XrefElement,
                             collection: true
              base.attribute :eref,
                             Metanorma::Document::Components::Inline::ErefElement,
                             collection: true
              base.attribute :link,
                             Metanorma::Document::Components::Inline::LinkElement,
                             collection: true
              base.attribute :span,
                             Metanorma::Document::Components::Inline::SpanElement,
                             collection: true
            end

            def declare_structural_attributes_on(base)
              base.attribute :stem,
                             Metanorma::Document::Components::Inline::StemInlineElement,
                             collection: true
              base.attribute :concept,
                             Metanorma::Document::Components::Inline::ConceptElement,
                             collection: true
              base.attribute :fn,
                             Metanorma::Document::Components::Inline::FnElement,
                             collection: true
              base.attribute :bcp14,
                             Metanorma::Document::Components::Inline::Bcp14Element,
                             collection: true
              base.attribute :br,
                             Metanorma::Document::Components::Inline::BrElement,
                             collection: true
              base.attribute :tab,
                             Metanorma::Document::Components::Inline::TabElement,
                             collection: true
              base.attribute :bookmark,
                             Metanorma::Document::Components::IdElements::Bookmark,
                             collection: true
              base.attribute :image,
                             Metanorma::Document::Components::IdElements::Image,
                             collection: true
              base.attribute :index,
                             Metanorma::Document::Components::EmptyElements::IndexElement,
                             collection: true
              base.attribute :add, "Metanorma::Document::Elements::Add",
                             collection: true
              base.attribute :del, "Metanorma::Document::Elements::Del",
                             collection: true
            end

            def declare_rendered_display_attributes_on(base)
              base.attribute :fmt_stem,
                             Metanorma::Document::Components::Inline::FmtStemElement,
                             collection: true
              base.attribute :fmt_concept,
                             Metanorma::Document::Components::Inline::FmtConceptElement,
                             collection: true
              base.attribute :fmt_fn_label,
                             Metanorma::Document::Components::Inline::FmtFnLabelElement,
                             collection: true
              base.attribute :fmt_annotation_start,
                             Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
                             collection: true
              base.attribute :fmt_annotation_end,
                             Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
                             collection: true
            end
          end

          # Adds the `map_element` calls corresponding to every vocabulary
          # attribute. Call inside an `xml do ... end` block:
          #
          #   xml do
          #     element "span"
          #     mixed_content
          #     map_attribute "class", to: :class_attr
          #     map_content to: :text
          #     VocabularyXmlMapping.apply_inline_mappings(self)
          #   end
          module VocabularyXmlMapping
            INLINE_MAPPINGS = {
              "semx" => :semx,
              "em" => :em,
              "strong" => :strong,
              "sub" => :sub,
              "sup" => :sup,
              "tt" => :tt,
              "underline" => :underline,
              "strike" => :strike,
              "smallcap" => :smallcap,
              "br" => :br,
              "tab" => :tab,
              "xref" => :xref,
              "eref" => :eref,
              "link" => :link,
              "span" => :span,
              "stem" => :stem,
              "concept" => :concept,
              "fn" => :fn,
              "bcp14" => :bcp14,
              "bookmark" => :bookmark,
              "image" => :image,
              "index" => :index,
              "add" => :add,
              "del" => :del,
              "fmt-stem" => :fmt_stem,
              "fmt-concept" => :fmt_concept,
              "fmt-fn-label" => :fmt_fn_label,
              "fmt-annotation-start" => :fmt_annotation_start,
              "fmt-annotation-end" => :fmt_annotation_end,
            }.freeze

            def self.apply_inline_mappings(mapping)
              INLINE_MAPPINGS.each do |element_name, attr_name|
                mapping.map_element(element_name, to: attr_name)
              end
            end
          end
        end
      end
    end
  end
end
