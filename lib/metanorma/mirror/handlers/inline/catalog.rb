# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Inline
        # Shared declarative table of inline marks whose HTML rendering is
        # a fixed tag with optional static attrs. Two adapters consume it:
        #
        # - RichHtmlRenderer: renders Metanorma XML elements to HTML
        #   directly (the fallback / attribute-value path).
        # - Output::HtmlRenderers::MarkRenderers: renders mirror Model marks
        #   to HTML (the primary SSR path).
        #
        # Both adapters must produce visually equivalent HTML for the same
        # mark type — the table is the single source of truth for the
        # mark-name to tag-and-attrs mapping. Marks whose attrs vary per
        # instance (link, xref, eref, span) carry data in mark.attrs and
        # are not in this table; each adapter keeps custom handlers for
        # those.
        module Catalog
          SIMPLE_WRAPS = {
            "emphasis"    => { tag: :em },
            "strong"      => { tag: :strong },
            "subscript"   => { tag: :sub },
            "superscript" => { tag: :sup },
            "code"        => { tag: :code },
            "underline"   => { tag: :u },
            "strike"      => { tag: :s },
            "smallcap"    => { tag: :span, style: "font-variant: small-caps" },
            "concept"     => { tag: :span, class: "concept" },
            "bcp14"       => { tag: :span, class: "bcp14" },
            "footnote"    => { tag: :sup, class: "footnote-inline" },
            "stem"        => { tag: :span, class: "stem" },
          }.freeze

          # XML element classes that render via SIMPLE_WRAPS without
          # per-instance attrs. Maps element class → mark type (catalog
          # key). RichHtmlRenderer uses this to dispatch simple elements
          # through the shared table.
          SIMPLE_ELEMENTS = {
            Metanorma::Document::Components::Inline::EmRawElement => "emphasis",
            Metanorma::Document::Components::Inline::StrongRawElement => "strong",
            Metanorma::Document::Components::Inline::SubElement => "subscript",
            Metanorma::Document::Components::Inline::SupElement => "superscript",
            Metanorma::Document::Components::Inline::TtElement => "code",
            Metanorma::Document::Components::TextElements::UnderlineElement => "underline",
            Metanorma::Document::Components::TextElements::StrikeElement => "strike",
            Metanorma::Document::Components::Inline::SmallCapElement => "smallcap",
            Metanorma::Document::Components::Inline::Bcp14Element => "bcp14",
            Metanorma::Document::Components::Inline::ConceptElement => "concept",
          }.freeze
        end
      end
    end
  end
end
