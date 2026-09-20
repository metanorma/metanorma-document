# frozen_string_literal: true

module Metanorma
  module UnDocument
    # UN TextElement restriction, per the current UN grammar
    # (metanorma-un, lib/metanorma/un/un.rng v1.2.1):
    #
    #   TextElement = text | em | eref | erefstack | strong | stem | sub |
    #                 sup | tt | strike | smallcap | xref | br | hyperlink |
    #                 bookmark
    #
    # UN allows only a strict subset of the isodoc inline vocabulary.
    # Enforcing this structurally would require a UN-specific variant of every
    # block type carrying inline content; instead this module validates the
    # parsed model graph, flagging instances of excluded inline element
    # classes found in inline content.
    #
    # Grammar-inline productions with no model class (date_inline) cannot be
    # flagged here; the parser drops them before validation can see them.
    module UnTextElement
      # Inline element names (grammar names) permitted in UN inline content.
      # `hyperlink` is the grammar production for the `<link>` element.
      ALLOWED_ELEMENTS = %w[
        em eref erefstack strong stem sub sup tt strike smallcap
        xref br link bookmark
      ].freeze

      # Model classes of the isodoc TextElement productions the UN grammar
      # excludes, mapped to their grammar (XML element) names.
      EXCLUDED_ELEMENTS = {
        Metanorma::Document::Components::TextElements::UnderlineElement => "underline",
        Metanorma::Document::Components::TextElements::KeywordElement => "keyword",
        Metanorma::Document::Components::TextElements::RubyElement => "ruby",
        Metanorma::Document::Components::EmptyElements::HorizontalRuleElement => "hr",
        Metanorma::Document::Components::EmptyElements::PageBreakElement => "pagebreak",
        Metanorma::Document::Components::IdElements::Image => "image",
        Metanorma::Document::Components::EmptyElements::IndexElement => "index",
        Metanorma::Document::Components::ReferenceElements::IndexXrefElement => "index-xref",
        Metanorma::Document::Components::Inline::ConceptElement => "concept",
        Metanorma::Document::Elements::Add => "add",
        Metanorma::Document::Elements::Del => "del",
        Metanorma::Document::Components::Inline::SpanElement => "span",
      }.freeze

      # Model classes whose content model is inline text; an excluded instance
      # under one of these is an inline use. Block-level occurrences (e.g.
      # Image under FigureBlock, PageBreakElement under ClauseSection) are
      # legal. ParagraphWithFootnote inherits from ParagraphBlock.
      INLINE_CONTAINERS = [
        Metanorma::Document::Components::Paragraphs::ParagraphBlock,
        Metanorma::Document::Components::Inline::TitleWithAnnotationElement,
        Metanorma::Document::Components::Inline::VariantTitleElement,
        Metanorma::Document::Components::TextElements::TextElement,
        Metanorma::Document::Components::Lists::DtElement,
        Metanorma::Document::Components::Tables::TableCell,
      ].freeze

      # fmt-* classes wrap presentation-rendered copies of content, where
      # `<span>` is rendering furniture rather than semantic inline markup.
      FURNITURE_CLASS_PATTERN = /(^|::)Fmt/

      # Returns an array of human-readable error strings for every excluded
      # inline element instance in the given model tree; empty when valid.
      def self.validate(model)
        errors = []
        walk(model, false, errors, {}.compare_by_identity)
        errors
      end

      def self.walk(node, inline, errors, visited)
        return unless node.is_a?(Lutaml::Model::Serializable)
        return if visited[node]

        visited[node] = true

        furniture = furniture?(node)
        excluded = furniture ? nil : excluded_name(node)
        if inline && excluded
          errors << "UN grammar forbids <#{excluded}> in inline " \
                    "content (#{node.class.name})"
        end

        child_inline = furniture ? false : inline || inline_container?(node)
        each_child(node) { |child| walk(child, child_inline, errors, visited) }
      end

      # Iterates the model-valued children of a node. Attribute values are
      # read via instance_variable_get, mirroring lutaml-model's own
      # attribute access (Serialize#validate_attribute!) — the project's
      # invariant specs forbid dynamic dispatch methods in model code.
      def self.each_child(node)
        node.class.attributes.each_key do |name|
          value = node.instance_variable_get(:"@#{name}")
          if value.is_a?(Enumerable) && !value.is_a?(String)
            value.each { |item| yield item if item.is_a?(Lutaml::Model::Serializable) }
          elsif value.is_a?(Lutaml::Model::Serializable)
            yield value
          end
        end
      end

      def self.excluded_name(node)
        pair = EXCLUDED_ELEMENTS.find { |klass, _| node.is_a?(klass) }
        pair&.last
      end

      def self.inline_container?(node)
        INLINE_CONTAINERS.any? { |klass| node.is_a?(klass) }
      end

      def self.furniture?(node)
        FURNITURE_CLASS_PATTERN.match?(node.class.name)
      end
    end
  end
end
