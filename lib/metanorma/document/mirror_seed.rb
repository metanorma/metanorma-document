# frozen_string_literal: true

module Metanorma
  module Document
    # Registers this gem's model knowledge into the metanorma-mirror
    # format gem. Components-based handlers run through the lazy
    # register_default hook; the class tables (mark builders, simple
    # mark types, rich renderers, text substitutions, semx classes),
    # the inline content iterator, and the Components part of the
    # positional id categories register eagerly — none of them touch
    # constants outside this gem. metanorma-standoc seeds the section
    # and structural handlers and its own id categories when it loads.
    class MirrorSeed
      MARK_BUILDERS = {
        Components::Inline::EmRawElement => ->(_el) {
          Mirror::Handlers.build_mark("emphasis")
        },
        Components::Inline::StrongRawElement => ->(_el) {
          Mirror::Handlers.build_mark("strong")
        },
        Components::Inline::SubElement => ->(_el) {
          Mirror::Handlers.build_mark("subscript")
        },
        Components::Inline::SupElement => ->(_el) {
          Mirror::Handlers.build_mark("superscript")
        },
        Components::Inline::TtElement => ->(_el) {
          Mirror::Handlers.build_mark("code")
        },
        Components::TextElements::UnderlineElement => ->(_el) {
          Mirror::Handlers.build_mark("underline")
        },
        Components::TextElements::StrikeElement => ->(_el) {
          Mirror::Handlers.build_mark("strike")
        },
        Components::Inline::SmallCapElement => ->(_el) {
          Mirror::Handlers.build_mark("smallcap")
        },
        Components::Inline::Bcp14Element => ->(_el) {
          Mirror::Handlers.build_mark("bcp14")
        },
        Components::Inline::LinkElement => ->(el) {
          attrs = {
            href: Mirror::SafeAttr.read(el, :target) ||
              Mirror::SafeAttr.read(el, :href),
          }.compact
          Mirror::Handlers.build_mark("link", attrs: attrs)
        },
        Components::Inline::XrefElement => ->(el) {
          attrs = { target: Mirror::SafeAttr.read(el, :target) }.compact
          Mirror::Handlers.build_mark("xref", attrs: attrs)
        },
        Components::Inline::ErefElement => ->(el) {
          attrs = {
            bibitemid: Mirror::SafeAttr.read(el, :bibitemid),
            citeas: Mirror::SafeAttr.read(el, :citeas),
          }.compact
          Mirror::Handlers.build_mark("eref", attrs: attrs)
        },
        Components::Inline::FnElement => ->(el) {
          attrs = {
            id: Mirror::SafeAttr.read(el, :id),
            reference: Mirror::SafeAttr.read(el, :reference),
          }.compact
          Mirror::Handlers.build_mark("footnote", attrs: attrs)
        },
        Components::Inline::StemInlineElement => ->(el) {
          attrs = { stem_type: Mirror::SafeAttr.read(el, :stem_type) ||
            "MathML" }
          math = Mirror::SafeAttr.read(el, :math)
          attrs[:mathml] = Mirror::MathUtil.mathml_from_math(math) if math
          Mirror::Handlers.build_mark("stem", attrs: attrs.compact)
        },
        Components::Inline::ConceptElement => ->(el) {
          attrs = {
            refterm: Mirror::SafeAttr.read(el, :refterm),
            renderterm: Mirror::SafeAttr.read(el, :renderterm),
          }.compact
          Mirror::Handlers.build_mark("concept", attrs: attrs)
        },
        Components::Inline::SpanElement => ->(el) {
          attrs = {
            class_attr: Mirror::SafeAttr.read(el, :class_attr),
            style: Mirror::SafeAttr.read(el, :style),
          }.compact
          Mirror::Handlers.build_mark("span", attrs: attrs)
        },
        Components::TextElements::RubyElement => ->(el) {
          pron = Mirror::SafeAttr.read(el, :pronunciation)
          ann = Mirror::SafeAttr.read(el, :annotation)
          attrs = {
            pronunciation: pron && Mirror::SafeAttr.read(pron, :value),
            annotation: ann && Mirror::SafeAttr.read(ann, :value),
            ruby_text: Array(Mirror::SafeAttr.read(el, :ruby_text)).join,
          }.compact
          Mirror::Handlers.build_mark("ruby", attrs: attrs)
        },
      }.freeze

      SIMPLE_MARK_TYPES = {
        Components::Inline::EmRawElement => "emphasis",
        Components::Inline::StrongRawElement => "strong",
        Components::Inline::SubElement => "subscript",
        Components::Inline::SupElement => "superscript",
        Components::Inline::TtElement => "code",
        Components::TextElements::UnderlineElement => "underline",
        Components::TextElements::StrikeElement => "strike",
        Components::Inline::SmallCapElement => "smallcap",
        Components::Inline::Bcp14Element => "bcp14",
        Components::Inline::ConceptElement => "concept",
      }.freeze

      RICH_RENDERERS = {
        Components::Inline::StemInlineElement => ->(el) {
          Renderer.for_stem(el)
        },
        Components::TextElements::StemElement => ->(el) {
          Renderer.for_stem(el)
        },
        Components::Inline::XrefElement => ->(el) {
          Renderer.for_xref(el)
        },
        Components::Inline::LinkElement => ->(el) {
          Renderer.for_link(el)
        },
        Components::Inline::ErefElement => ->(el) {
          Renderer.for_eref(el)
        },
        Components::Inline::FnElement => ->(el) {
          Renderer.for_fn(el)
        },
        Components::Inline::SpanElement => ->(el) {
          Renderer.for_span(el)
        },
        Components::Inline::BrElement => ->(_el) {
          Renderer.wrap(&:br)
        },
      }.freeze

      Renderer = Mirror::Handlers::Inline::RichHtmlRenderer

      POSITIONAL_CATEGORIES = {
        Components::AncillaryBlocks::FigureBlock => :figure,
        Components::Tables::TableBlock => :table,
      }.freeze

      class << self
        def register
          register_handler_hook
          register_tables
          register_iterator
          register_positional_categories
        end

        private

        def register_handler_hook
          Mirror.register_default do |registry|
            registry.register(
              Components::Paragraphs::ParagraphBlock,
              Mirror::Handlers::Paragraph,
            )
            registry.register(
              Components::Blocks::NoteBlock, Mirror::Handlers::Note
            )
            registry.register(
              Components::MultiParagraph::AdmonitionBlock,
              Mirror::Handlers::Admonition,
            )
            registry.register(
              Components::AncillaryBlocks::ExampleBlock,
              Mirror::Handlers::Example,
            )
            registry.register(
              Components::AncillaryBlocks::FigureBlock,
              Mirror::Handlers::Figure,
            )
            registry.register(
              Components::AncillaryBlocks::SvgmapElement,
              Mirror::Handlers::Svgmap,
            )
            registry.register(
              Components::AncillaryBlocks::ImagemapElement,
              Mirror::Handlers::Imagemap,
            )
            registry.register(
              Components::AncillaryBlocks::SourcecodeBlock,
              Mirror::Handlers::Sourcecode,
            )
            registry.register(
              Components::AncillaryBlocks::FormulaBlock,
              Mirror::Handlers::Formula,
            )
            registry.register(
              Components::MultiParagraph::QuoteBlock,
              Mirror::Handlers::Quote,
            )
            registry.register(
              Components::Tables::TableBlock, Mirror::Handlers::Table
            )
            registry.register(
              Components::MultiParagraph::ReviewBlock,
              Mirror::Handlers::Review,
            )
            registry.register(
              Components::Lists::UnorderedList,
              Mirror::Handlers::List, method_name: :bullet
            )
            registry.register(
              Components::Lists::OrderedList,
              Mirror::Handlers::List, method_name: :ordered
            )
            registry.register(
              Components::Lists::DefinitionList,
              Mirror::Handlers::List, method_name: :definition
            )
            registry.register(
              Components::Lists::ListItem,
              Mirror::Handlers::List, method_name: :list_item
            )
          end
        end

        def register_tables
          MARK_BUILDERS.each do |klass, builder|
            Mirror.mark_builders.register(klass, builder)
          end
          SIMPLE_MARK_TYPES.each do |klass, mark|
            Mirror.simple_inline_elements.register(klass, mark)
          end
          RICH_RENDERERS.each do |klass, renderer|
            Mirror.rich_html_renderers.register(klass, renderer)
          end
          Mirror.inline_text_substitutions
            .register(Components::Inline::TabElement, " ")
          Mirror.inline_text_substitutions
            .register(Components::Inline::BrElement, "\n")
          Mirror.semx_elements.register(Components::Inline::SemxElement, true)
        end

        def register_iterator
          Mirror.inline_content_iterator = Components::Inline::SemanticContent
        end

        def register_positional_categories
          POSITIONAL_CATEGORIES.each do |klass, category|
            Mirror::IdStrategy::Positional.register_category(klass, category)
          end
        end
      end
    end
  end
end
