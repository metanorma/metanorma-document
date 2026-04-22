module Metanorma
  module Document
    module Components
      module Inline
        class SemxElement < Lutaml::Model::Serializable
          attribute :element_attr, :string
          attribute :source, :string
          attribute :text, :string, collection: true
          attribute :fmt_xref, "Metanorma::Document::Components::Inline::FmtXrefElement",
                    collection: true
          attribute :asciimath, AsciimathElement, collection: true
          attribute :math, MathElement, collection: true
          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true
          attribute :semx, "Metanorma::Document::Components::Inline::SemxElement",
                    collection: true
          attribute :strong, StrongRawElement, collection: true
          attribute :origin, ErefElement, collection: true
          attribute :em, EmRawElement, collection: true
          attribute :fmt_link, LinkElement, collection: true
          attribute :sup, SupElement, collection: true
          attribute :span, "Metanorma::Document::Components::Inline::SpanElement",
                    collection: true
          attribute :xref, XrefElement, collection: true
          attribute :eref, ErefElement, collection: true

          # Term/metadata child elements
          attribute :title_child, SemxChildElement, collection: true
          attribute :name_child, SemxChildElement, collection: true
          attribute :preferred_child, SemxChildElement, collection: true
          attribute :admitted_child, SemxChildElement, collection: true
          attribute :deprecates_child, SemxChildElement, collection: true
          attribute :domain_child, SemxChildElement, collection: true
          attribute :definition_child, SemxChildElement, collection: true
          attribute :verbal_definition_child, SemxChildElement, collection: true
          attribute :identifier_child, SemxChildElement, collection: true
          attribute :source_child, SemxChildElement, collection: true
          attribute :author_child, SemxChildElement, collection: true
          attribute :callout_annotation_child, SemxChildElement,
                    collection: true
          attribute :modification_child, SemxChildElement, collection: true
          attribute :annotation_child, SemxChildElement, collection: true

          # Existing model classes reused inside semx
          attribute :stem_child, StemInlineElement, collection: true
          attribute :concept_child, ConceptElement, collection: true
          attribute :fn_child, FnElement, collection: true
          attribute :link_child, LinkElement, collection: true
          attribute :sub_child, SubElement, collection: true
          attribute :tt_child, TtElement, collection: true
          attribute :br_child, BrElement, collection: true
          attribute :tab_child, TabElement, collection: true

          # Block elements inside semx
          attribute :figure_child, "Metanorma::Document::Components::AncillaryBlocks::FigureBlock",
                    collection: true
          attribute :formula_child, "Metanorma::Document::Components::AncillaryBlocks::FormulaBlock",
                    collection: true
          attribute :sourcecode_child, "Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock",
                    collection: true

          xml do
            element "semx"
            mixed_content
            map_attribute "element", to: :element_attr
            map_attribute "source", to: :source
            map_content to: :text
            map_element "fmt-xref", to: :fmt_xref
            map_element "asciimath", to: :asciimath
            map_element "math", to: :math
            map_element "p", to: :p
            map_element "semx", to: :semx
            map_element "strong", to: :strong
            map_element "origin", to: :origin
            map_element "em", to: :em
            map_element "fmt-link", to: :fmt_link
            map_element "sup", to: :sup
            map_element "span", to: :span
            map_element "xref", to: :xref
            map_element "eref", to: :eref
            # Term/metadata children
            map_element "title", to: :title_child
            map_element "name", to: :name_child
            map_element "preferred", to: :preferred_child
            map_element "admitted", to: :admitted_child
            map_element "deprecates", to: :deprecates_child
            map_element "domain", to: :domain_child
            map_element "definition", to: :definition_child
            map_element "verbal-definition", to: :verbal_definition_child
            map_element "identifier", to: :identifier_child
            map_element "source", to: :source_child
            map_element "author", to: :author_child
            map_element "callout-annotation", to: :callout_annotation_child
            map_element "modification", to: :modification_child
            map_element "annotation", to: :annotation_child
            # Reused model classes
            map_element "stem", to: :stem_child
            map_element "concept", to: :concept_child
            map_element "fn", to: :fn_child
            map_element "link", to: :link_child
            map_element "sub", to: :sub_child
            map_element "tt", to: :tt_child
            map_element "br", to: :br_child
            map_element "tab", to: :tab_child
            # Block children
            map_element "figure", to: :figure_child
            map_element "formula", to: :formula_child
            map_element "sourcecode", to: :sourcecode_child
          end
        end
      end
    end
  end
end
