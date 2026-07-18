# frozen_string_literal: true

require "liquid"
require "nokogiri"
require "cgi"

module Metanorma
  module Html
    module Renderers
      autoload :InlineRenderer, "metanorma/html/renderers/inline_renderer"
      autoload :BlockRenderer, "metanorma/html/renderers/block_renderer"
      autoload :SectionRenderer, "metanorma/html/renderers/section_renderer"
      autoload :PubidRenderer, "metanorma/html/renderers/pubid_renderer"
      autoload :ElementOrderTraversal,
               "metanorma/html/renderers/element_order_traversal"
    end

    module Concerns
      autoload :MetadataExtraction,
               "metanorma/html/concerns/metadata_extraction"
      autoload :PresentationValidation,
               "metanorma/html/concerns/presentation_validation"
      autoload :SvgProcessing, "metanorma/html/concerns/svg_processing"
      autoload :TextExtraction, "metanorma/html/concerns/text_extraction"
      autoload :TocRegistry, "metanorma/html/concerns/toc_registry"
    end

    class BaseRenderer
      include Concerns::MetadataExtraction
      include Concerns::PresentationValidation
      include Concerns::SvgProcessing
      include Concerns::TextExtraction
      include Concerns::TocRegistry

      LOGO_DIR = File.expand_path("../../../data/logos", __dir__)

      SPAN_ROLE_CLASSES = {
        "boldtitle" => "title-text",
        "nonboldtitle" => "subtitle-text",
        "citeapp" => "xref-app",
        "citefig" => "xref-fig",
        "citesec" => "xref-section",
        "citetbl" => "xref-table",
        "fmt-autonum-delim" => "number-delim",
        "fmt-caption-label" => "caption-label",
        "fmt-caption-delim" => "caption-delim",
        "fmt-element-name" => "element-label",
        "fmt-comma" => "comma",
        "fmt-conn" => "connector",
        "fmt-label-delim" => "label-delim",
        "fmt-obligation" => "obligation-text",
        "fmt-xref-container" => "xref-container",
        "fmt-xref-label" => "xref-label",
        "std_publisher" => "ref-publisher",
        "stdpublisher" => "ref-publisher-name",
        "stddocNumber" => "ref-doc-number",
        "stddocTitle" => "ref-title",
        "stddocPartNumber" => "ref-part-number",
        "stdyear" => "ref-year",
        "date" => "date",
        "smallcap" => "small-caps",
      }.freeze

      METANORMA_LOGO = "metanorma-logo.svg"

      class << self
        def render_registry
          @render_registry ||= {}
        end

        def register_render(type_class, method_name)
          render_registry[type_class] = method_name
        end

        def inline_registry
          @inline_registry ||= {}
        end

        def register_inline_render(type_class, method_name)
          inline_registry[type_class] = method_name
        end
      end

      attr_reader :inline_renderer, :block_renderer, :section_renderer,
                  :pubid_renderer, :index_term_collector, :footnote_collector
      private :inline_renderer, :block_renderer, :section_renderer,
              :pubid_renderer

      def initialize
        @toc_entries = []
        @figure_entries = []
        @table_entries = []
        @index_term_collector = Component::IndexTermCollector.new
        @footnote_collector = Component::FootnoteCollector.new
        @current_section_id = nil
        @current_section_number = nil

        @inline_renderer = Renderers::InlineRenderer.new(self)
        @block_renderer = Renderers::BlockRenderer.new(self)
        @section_renderer = Renderers::SectionRenderer.new(self)
        @pubid_renderer = Renderers::PubidRenderer.new(self)
      end

      class RendererContext
        include RendererDelegation

        def initialize(renderer)
          @renderer = renderer
        end

        def render_paragraph(...) = @renderer.render_paragraph(...)
        def render_inline_element(...)= @renderer.render_inline_element(...)
        def render_unordered_list(...)= @renderer.render_unordered_list(...)
        def render_ordered_list(...)= @renderer.render_ordered_list(...)
        def render_definition_list(...)= @renderer.render_definition_list(...)
        def render_sourcecode(...)  = @renderer.render_sourcecode(...)
        def render_table(...)       = @renderer.render_table(...)
        def render_figure(...)      = @renderer.render_figure(...)
        def render_quote(...)       = @renderer.render_quote(...)
        def render_formula(...)     = @renderer.render_formula(...)
        def render_note(...)        = @renderer.render_note(...)
        def render_image(...)       = @renderer.render_image(...)
        def render_stem_content(...)= @renderer.render_stem_content(...)
        def register_figure_entry(...)= @renderer.register_figure_entry(...)
        def render_note_children(...) = @renderer.render_note_children(...)
        def render_simple_children(...) = @renderer.render_simple_children(...)
        def render_full_block_children(...) = @renderer.render_full_block_children(...)
      end

      def renderer_context
        @renderer_context ||= RendererContext.new(self)
      end

      attr_writer :document, :theme

      def generate_full_document(document, theme: nil, **)
        @document = document
        @theme_override = theme
        validate_presentation_xml!

        body = render(@document) || ""

        assemble_document(body)
      end

      # Renders only the document body content (no html/head/styles
      # assembly) — for embedding classic-rendered content into a host page.
      def generate_body(document, **)
        @document = document
        validate_presentation_xml!
        render(@document) || ""
      end

      # --- Flavor configuration hooks ---

      def theme
        @theme ||= resolve_theme
      end

      def resolve_theme
        return load_theme_override(@theme_override) if @theme_override

        flavor = flavor_name
        flavor ? Theme.load(flavor) : Theme.new
      end

      # A theme override given to Generator.generate: a Theme instance,
      # a path to a theme directory (theme.yaml with assets/, templates/
      # and custom.css alongside), or a path to a bare theme.yaml file.
      # This is how an organization customizes the output without
      # changing any code.
      def load_theme_override(override)
        return override if override.is_a?(Theme)

        if File.directory?(override)
          Theme.from_theme_dir(override)
        else
          Theme.from_file(override)
        end
      end

      def flavor_name
        return nil unless defined?(@document) && @document

        Metanorma::Html::Generator.flavors.name_for(@document.class)
      end

      # Pubid module for the current document's flavor, or nil if the
      # flavor has no Pubid support. Queries the shared FlavorRegistry.
      def pubid_module
        return nil unless defined?(@document) && @document

        Metanorma::Html::Generator.flavors.pubid_module_for(@document.class)
      end

      def flavor_publishers(_doc_id)
        theme.publishers
      end

      def flavor_publisher_name
        theme.publisher_name
      end

      def publisher_logo_map
        theme.logos_light
      end

      def flavor_font_url
        theme.font_url
      end

      # --- Document Assembly ---

      TEMPLATE_CACHE = {} # rubocop:disable Style/MutableConstant
      TEMPLATE_CACHE_MUTEX = Mutex.new

      def render_liquid(template_name, assigns)
        template_path = theme.resolve_template(template_name)
        template = TEMPLATE_CACHE_MUTEX.synchronize do
          TEMPLATE_CACHE[template_path] ||= Liquid::Template.parse(File.read(template_path))
        end
        assigns = assigns.transform_keys(&:to_s) if assigns.is_a?(Hash)
        template.render(assigns)
      end

      def assemble_document(body)
        toc_html = build_toc_html(@toc_entries)
        header = build_header
        footer = build_footer

        render_liquid("document.html.liquid", {
                        "lang" => language,
                        "title" => html_title,
                        "font_url" => flavor_font_url,
                        "styles" => build_styles,
                        "header" => header,
                        "toc" => toc_html,
                        "body" => body,
                        "footer" => footer,
                        "scripts" => build_scripts,
                      })
      end

      # --- Header and Footer ---

      def build_header
        doc_id = extract_primary_doc_id
        pub_logos = build_publisher_logos
        pub_name = flavor_publisher_name
        display_id = if pub_name && doc_id && !doc_id.start_with?(pub_name)
                       "#{pub_name} #{doc_id}"
                     else
                       doc_id
                     end

        render_liquid("_header.html.liquid", {
                        "publisher_logos" => pub_logos,
                        "doc_id" => display_id,
                        "doc_title" => header_title_text,
                      })
      end

      def header_title_text
        raw = html_title.to_s.split(" — ").first.to_s
        raw.length > 60 ? "#{raw[0, 57]}..." : raw
      end

      def build_publisher_logos
        publishers = flavor_publishers(extract_primary_doc_id)
        logo_map = publisher_logo_map
        return "" if publishers.empty? && logo_map.empty?

        dark_logo_map = theme.logos_dark
        display_pubs = publishers.empty? ? logo_map.keys : publishers

        display_pubs.filter_map do |pub|
          filename = logo_map[pub]
          next unless filename

          svg = load_logo_svg(filename, height: 26)
          next unless svg

          light_span = "<span class=\"brand-logo brand-logo-light\" aria-label=\"#{pub} logo\">#{svg}</span>"

          dark_span = ""
          dark_filename = dark_logo_map[pub]
          if dark_filename
            dark_svg = load_logo_svg(dark_filename, height: 26)
            if dark_svg
              dark_span = "<span class=\"brand-logo brand-logo-dark\" aria-label=\"#{pub} logo\">#{dark_svg}</span>"
            end
          end

          "#{light_span}\n#{dark_span}"
        end.join("\n")
      end

      def build_footer
        mn_logo = load_logo_svg(METANORMA_LOGO, height: 20)
        render_liquid("_footer.html.liquid", {
                        "mn_logo" => mn_logo,
                        "generated_at" => Time.now.strftime("%Y-%m-%d %H:%M"),
                      })
      end

      # --- Scripts ---

      def build_scripts
        pipeline = AssetPipeline.new
        compiled = pipeline.compile_js(flavor_js: flavor_js_module)
        "<script>\n#{compiled}\n</script>"
      end

      def flavor_js_module
        nil
      end

      def flavor_css_module
        nil
      end

      def build_styles
        pipeline = AssetPipeline.new
        css = pipeline.compile_css(flavor_css: flavor_css_module)
        parts = [theme.to_css_root, css, theme.to_css_extras]
        custom_css_path = theme.theme_css_path
        parts << File.read(custom_css_path) if custom_css_path
        parts.join("\n")
      end

      # --- Dispatch ---

      def render(node, **)
        return escape_html(node) if node.is_a?(String)

        method = lookup_dispatch(node.class, :render_registry)
        return public_send(method, node, **) if method

        record_render_warning(
          "no renderer registered for #{node.class} — content skipped",
        )
        ""
      end

      # Emit a render warning once per distinct message. Warnings mark
      # content that was skipped or degraded rather than rendered.
      def record_render_warning(message)
        @render_warnings ||= {}
        return if @render_warnings.key?(message)

        @render_warnings[message] = true
        warn "metanorma-document: #{message}"
      end

      def render_inline_element(element, **)
        @inline_renderer.render_inline_element(element)
      end

      def is_title_element?(node, section)
        title = safe_attr(section, :title)
        return false unless title

        node.equal?(title)
      end

      # --- Type registrations ---

      register_render Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                      :render_paragraph
      register_render Metanorma::Document::Components::Tables::TableBlock,
                      :render_table
      register_render Metanorma::Document::Components::Lists::UnorderedList,
                      :render_unordered_list
      register_render Metanorma::Document::Components::Lists::OrderedList,
                      :render_ordered_list
      register_render Metanorma::Document::Components::Lists::DefinitionList,
                      :render_definition_list
      register_render Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                      :render_figure
      register_render Metanorma::Document::Components::Blocks::NoteBlock,
                      :render_note
      register_render Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                      :render_example
      register_render Metanorma::StandardDocument::Blocks::Form,
                      :render_form
      register_render Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
                      :render_sourcecode
      register_render Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
                      :render_formula
      register_render Metanorma::Document::Components::MultiParagraph::QuoteBlock,
                      :render_quote
      register_render Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
                      :render_admonition
      register_render Metanorma::Document::Components::Sections::HierarchicalSection,
                      :render_hierarchical_section
      register_render Metanorma::Document::Components::Sections::BasicSection,
                      :render_basic_section
      register_render Metanorma::Document::Components::Sections::ContentSection,
                      :render_content_section
      register_render Metanorma::Document::Components::EmptyElements::PageBreakElement,
                      :render_noop
      register_render Metanorma::Document::Components::IdElements::Bookmark,
                      :render_bookmark
      register_render Metanorma::Document::Components::Inline::SemxElement,
                      :render_semx_content

      register_inline_render Metanorma::Document::Components::Inline::EmRawElement,
                             :render_em
      register_inline_render Metanorma::Document::Components::Inline::StrongRawElement,
                             :render_strong
      register_inline_render Metanorma::Document::Components::Inline::TtElement,
                             :render_tt
      register_inline_render Metanorma::Document::Components::Inline::SubElement,
                             :render_sub
      register_inline_render Metanorma::Document::Components::Inline::SupElement,
                             :render_sup
      register_inline_render Metanorma::Document::Components::Inline::SmallCapElement,
                             :render_small_caps
      register_inline_render Metanorma::Document::Components::TextElements::UnderlineElement,
                             :render_underline
      register_inline_render Metanorma::Document::Components::TextElements::StrikeElement,
                             :render_strike
      register_inline_render Metanorma::Document::Components::Inline::BrElement,
                             :render_br
      register_inline_render Metanorma::Document::Components::Inline::TabElement,
                             :render_tab
      register_inline_render Metanorma::Document::Components::Inline::LinkElement,
                             :render_link
      register_inline_render Metanorma::Document::Components::Inline::XrefElement,
                             :render_noop_inline
      register_inline_render Metanorma::Document::Components::Inline::ErefElement,
                             :render_noop_inline
      register_inline_render Metanorma::Document::Components::Inline::SpanElement,
                             :render_span
      register_inline_render Metanorma::Document::Components::Inline::FnElement,
                             :render_fn_inline
      register_inline_render Metanorma::Document::Components::Inline::ConceptElement,
                             :render_concept
      register_inline_render Metanorma::Document::Components::Inline::StemInlineElement,
                             :render_noop_inline
      register_inline_render Metanorma::Document::Components::TextElements::StemElement,
                             :render_stem
      register_inline_render Metanorma::Document::Components::Inline::SemxElement,
                             :render_semx_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtXrefElement,
                             :render_fmt_xref
      register_inline_render Metanorma::Document::Components::Inline::FmtStemElement,
                             :render_fmt_stem
      register_inline_render Metanorma::Document::Components::Inline::CommaElement,
                             :render_comma
      register_inline_render Metanorma::StandardDocument::Elements::Input,
                             :render_input
      register_inline_render Metanorma::Document::Components::Inline::EnumCommaElement,
                             :render_comma
      register_inline_render Metanorma::Document::Components::IdElements::Bookmark,
                             :render_bookmark
      register_inline_render Metanorma::Document::Components::IdElements::Image,
                             :render_image
      register_inline_render Metanorma::Document::Components::Inline::MathElement,
                             :render_math
      register_inline_render Metanorma::Document::Components::Inline::AsciimathElement,
                             :render_asciimath
      register_inline_render Metanorma::Document::Components::EmptyElements::IndexElement,
                             :render_index
      register_inline_render Metanorma::Document::Components::ReferenceElements::IndexXrefElement,
                             :render_index
      register_inline_render Metanorma::Document::Components::Blocks::NoteBlock,
                             :render_note_inline

      # Transparent inline wrappers: element classes whose render
      # semantics are "iterate mixed_content and render each child".
      # Grouped here so adding a new transparent wrapper is one entry,
      # not another register_inline_render line. Classes with a more
      # specific handler register themselves above.
      TRANSPARENT_INLINE_WRAPPERS = [
        Metanorma::Document::Components::Inline::FmtNameElement,
        Metanorma::Document::Components::Inline::FmtTitleElement,
        Metanorma::Document::Components::Inline::FmtXrefLabelElement,
        Metanorma::Document::Components::Inline::FmtFnLabelElement,
        Metanorma::Document::Components::Inline::FmtConceptElement,
        Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
        Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
        Metanorma::Document::Components::Inline::FmtAnnotationBodyElement,
        Metanorma::Document::Components::Inline::VariantTitleElement,
        Metanorma::Document::Components::Inline::LocalizedStringElement,
        Metanorma::Document::Components::Inline::TitleWithAnnotationElement,
        Metanorma::Document::Components::Inline::BiblioTagElement,
        Metanorma::Document::Components::Inline::NameWithIdElement,
        Metanorma::Document::Components::Inline::DisplayTextElement,
        Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
        Metanorma::Document::Components::Inline::FmtFnBodyElement,
        Metanorma::Document::Components::Inline::FmtPreferredElement,
        Metanorma::Document::Components::Inline::FmtDefinitionElement,
        Metanorma::Document::Components::Inline::FmtTermsourceElement,
        Metanorma::Document::Components::Inline::FmtAdmittedElement,
        Metanorma::Document::Components::Inline::FmtIdentifierElement,
        Metanorma::Document::Components::Inline::FmtSourcecodeElement,
      ].freeze

      TRANSPARENT_INLINE_WRAPPERS.each do |klass|
        register_inline_render klass, :render_mixed_inline
      end

      # Inline-ish classes that are also reached through the BLOCK
      # dispatch (as direct children of block containers, e.g. fmt-title
      # as a child of clause). fmt-title and variant-title duplicate the
      # semantic `title` attribute that sections render — skip them.
      register_render Metanorma::Document::Components::Inline::FmtTitleElement,
                      :render_noop
      register_render Metanorma::Document::Components::Inline::VariantTitleElement,
                      :render_noop
      # fmt-xref-label carries the cross-reference link label; render it
      # through when it appears in block context.
      register_render Metanorma::Document::Components::Inline::FmtXrefLabelElement,
                      :render_block_inline_content

      def lookup_dispatch(type_class, registry_method)
        # Registry contents are fixed once renderer classes are loaded, so
        # the resolved method per (registry, node class) is memoized for
        # the lifetime of this renderer instance.
        cache = (@dispatch_cache ||= {})
        key = [registry_method, type_class]
        return cache[key] if cache.key?(key)

        cache[key] = resolve_dispatch(type_class, registry_method)
      end

      def resolve_dispatch(type_class, registry_method)
        self.class.ancestors.each do |ancestor|
          next unless ancestor.is_a?(Class) && (ancestor == BaseRenderer || ancestor < BaseRenderer)

          registry = ancestor.public_send(registry_method)
          method_name = registry[type_class]
          return method_name if method_name
        end
        nil
      end

      def render_noop(*)
        ""
      end

      # Block-dispatch entry point for inline content reached as a direct
      # child of a block container (render passes keyword args; the inline
      # pipeline does not accept them).
      def render_block_inline_content(el, **)
        render_mixed_inline(el)
      end

      def render_noop_inline(*)
        nil
      end

      # --- Delegation to sub-renderers ---

      # Inline rendering delegation
      def walk_ordered(node, allow_filter: nil, &)
        @inline_renderer.walk_ordered(node, allow_filter: allow_filter, &)
      end

      def render_mixed_inline(node)
        @inline_renderer.render_mixed_inline(node)
      end

      def render_cell_content(cell) = @inline_renderer.render_cell_content(cell)
      def render_em(el) = @inline_renderer.render_em(el)
      def render_strong(el) = @inline_renderer.render_strong(el)
      def render_tt(el) = @inline_renderer.render_tt(el)
      def render_sub(el) = @inline_renderer.render_sub(el)
      def render_sup(el) = @inline_renderer.render_sup(el)
      def render_small_caps(el) = @inline_renderer.render_small_caps(el)
      def render_underline(el) = @inline_renderer.render_underline(el)
      def render_strike(el) = @inline_renderer.render_strike(el)
      def render_br(*) = @inline_renderer.render_br
      def render_tab(*) = @inline_renderer.render_tab
      def render_span(el) = @inline_renderer.render_span(el)
      def render_fn_inline(el) = @inline_renderer.render_fn_inline(el)
      def render_stem(el) = @inline_renderer.render_stem(el)
      def render_semx_inline(el) = @inline_renderer.render_semx_inline(el)
      def render_fmt_xref(el) = @inline_renderer.render_fmt_xref(el)
      def render_comma(*) = @inline_renderer.render_comma
      def render_input(el) = @inline_renderer.render_input(el)
      def render_math(el) = @inline_renderer.render_math(el)
      def render_asciimath(el) = @inline_renderer.render_asciimath(el)
      def render_index(el) = @inline_renderer.render_index(el)
      def render_note_inline(el) = @inline_renderer.render_note_inline(el)

      def render_semx_content(el,
**)
        @inline_renderer.render_semx_content(el, **)
      end

      def render_stem_content(stem) = @inline_renderer.render_stem_content(stem)
      def render_link(link) = @inline_renderer.render_link(link)
      def render_xref(xref) = @inline_renderer.render_xref(xref)
      def render_eref(eref) = @inline_renderer.render_eref(eref)
      def render_fn(fn) = @inline_renderer.render_fn(fn)
      def render_concept(concept) = @inline_renderer.render_concept(concept)
      def render_fmt_stem(fmt_stem) = @inline_renderer.render_fmt_stem(fmt_stem)
      def render_mixed_content_in_order(node, **) = @inline_renderer.render_mixed_content_in_order(node, **)

      # Block rendering delegation
      def render_paragraph(p,
**)
        @block_renderer.render_paragraph(p, **)
      end

      def render_table(table,
**)
        @block_renderer.render_table(table, **)
      end

      def render_unordered_list(ul,
**)
        @block_renderer.render_unordered_list(ul, **)
      end

      def render_ordered_list(ol,
**)
        @block_renderer.render_ordered_list(ol, **)
      end

      def render_definition_list(dl,
**)
        @block_renderer.render_definition_list(dl, **)
      end

      def render_figure(figure,
**)
        @block_renderer.render_figure(figure, **)
      end

      def render_image(image) = @block_renderer.render_image(image)
      def render_video(video) = @block_renderer.render_video(video)
      def render_audio(audio) = @block_renderer.render_audio(audio)
      def render_note(note, **) = @block_renderer.render_note(note, **)

      def render_example(example,
**)
        @block_renderer.render_example(example, **)
      end

      def render_form(form, **) = @block_renderer.render_form(form, **)

      def render_sourcecode(sc,
**)
        @block_renderer.render_sourcecode(sc, **)
      end

      def render_formula(formula,
**)
        @block_renderer.render_formula(formula, **)
      end

      def render_quote(quote,
**)
        @block_renderer.render_quote(quote, **)
      end

      def render_admonition(admonition,
**)
        @block_renderer.render_admonition(admonition, **)
      end

      def render_bookmark(bookmark,
**)
        @block_renderer.render_bookmark(bookmark, **)
      end

      def render_block_children(model,
children:)
        @block_renderer.render_block_children(model, children: children)
      end

      def render_note_children(model) = @block_renderer.render_note_children(model)
      def render_simple_children(model) = @block_renderer.render_simple_children(model)
      def render_full_block_children(model) = @block_renderer.render_full_block_children(model)

      # Section rendering delegation
      def render_basic_section(section,
**)
        @section_renderer.render_basic_section(section, **)
      end

      def render_hierarchical_section(section,
**)
        @section_renderer.render_hierarchical_section(section, **)
      end

      def render_content_section(section,
**)
        @section_renderer.render_content_section(section, **)
      end

      def render_ordered_content(section,
level = 1)
        @section_renderer.render_ordered_content(section, level)
      end

      def collect_ordered_children(section) = @section_renderer.collect_ordered_children(section)
      def sort_by_displayorder(children) = @section_renderer.sort_by_displayorder(children)

      def render_preface(preface,
**)
        @section_renderer.render_preface(preface, **)
      end

      # Pubid rendering delegation
      def parse_pubid(docidentifier_string) = @pubid_renderer.parse_pubid(docidentifier_string)
      def pubid_to_html(identifier) = @pubid_renderer.pubid_to_html(identifier)

      # --- Helper methods ---

      def element_attrs(**attrs)
        parts = []
        attrs.each do |k, v|
          next if v.nil? || v == false || (v.is_a?(String) && v.empty?)

          parts << %( #{k}="#{escape_html(v.to_s)}")
        end
        parts.join
      end

      BLOCK_TYPES = {
        Metanorma::Document::Components::Paragraphs::ParagraphBlock => true,
        Metanorma::Document::Components::Tables::TableBlock => true,
        Metanorma::Document::Components::Lists::UnorderedList => true,
        Metanorma::Document::Components::Lists::OrderedList => true,
        Metanorma::Document::Components::Lists::DefinitionList => true,
        Metanorma::Document::Components::AncillaryBlocks::FigureBlock => true,
        Metanorma::Document::Components::Blocks::NoteBlock => true,
        Metanorma::Document::Components::AncillaryBlocks::ExampleBlock => true,
        Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock => true,
        Metanorma::Document::Components::AncillaryBlocks::FormulaBlock => true,
        Metanorma::Document::Components::MultiParagraph::QuoteBlock => true,
        Metanorma::Document::Components::MultiParagraph::AdmonitionBlock => true,
        Metanorma::Document::Components::Sections::HierarchicalSection => true,
        Metanorma::Document::Components::Sections::BasicSection => true,
        Metanorma::Document::Components::Sections::ContentSection => true,
      }.freeze

      def html_class_for_span(xml_class)
        SPAN_ROLE_CLASSES[xml_class] || "span-#{xml_class}"
      end

      def block_element?(obj)
        BLOCK_TYPES[obj.class] || BLOCK_TYPES.any? { |type, _| obj.is_a?(type) }
      end

      def safe_attr(obj, method_name)
        if obj.is_a?(Lutaml::Model::Serializable) && !obj.class.attributes.key?(method_name)
          return nil
        end

        obj.public_send(method_name)
      rescue NoMethodError => e
        # Only swallow "method missing on this object" (duck-typing across
        # model classes). A NoMethodError raised *inside* the getter is a
        # real bug — let it surface.
        raise unless e.receiver.equal?(obj)

        nil
      end

      def collect_index_term(element)
        primary = safe_attr(element, :primary)
        return unless primary && !primary.to_s.strip.empty?

        @index_term_collector.add(
          primary: primary.to_s.strip,
          secondary: safe_attr(element, :secondary)&.to_s&.strip,
          tertiary: safe_attr(element, :tertiary)&.to_s&.strip,
          target_id: @current_section_id,
          target_text: @current_section_number,
        )
      rescue StandardError => e
        record_render_warning("index term dropped: #{e.class}: #{e.message}")
        nil
      end

      def extract_block_label(block, default)
        names = safe_attr(block, :name)
        if names && !names.empty?
          name = names.is_a?(Array) ? names.first : names
          text = extract_text_value(name)
          return text unless text.to_s.strip.empty?
        end

        autonum = safe_attr(block, :autonum)
        if autonum && !autonum.to_s.empty?
          number = autonum.to_s
          return "#{default} #{number}"
        end

        default
      end

      def alignment_style(alignment)
        return nil if alignment.nil? || alignment.to_s.empty?

        "text-align: #{alignment}"
      end

      def extract_title_text(titles)
        return "" if titles.nil?
        return extract_text_value(titles).to_s unless titles.is_a?(Array)
        return "" if titles.empty?

        title = titles.first
        extract_text_value(title).to_s
      end

      def escape_html(text)
        CGI.escapeHTML(text.to_s)
      end

      def render_footnotes_section
        return nil if @footnote_collector.empty?

        drops = @footnote_collector.to_a.map do |entry|
          content_html = ""
          if entry.content && !entry.content.empty?
            content_html = Array(entry.content).filter_map do |p|
              render_paragraph(p)
            end.join
          end
          Drops::FootnoteDrop.new(entry, content_html)
        end

        render_liquid("_footnotes.html.liquid",
                      { "footnotes" => drops })
      end
    end
  end
end
