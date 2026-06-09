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
    end

    class BaseRenderer
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
        def initialize(renderer)
          @renderer = renderer
        end

        def safe_attr(...)        = @renderer.safe_attr(...)
        def escape_html(...)      = @renderer.escape_html(...)
        def extract_block_label(...)= @renderer.extract_block_label(...)
        def extract_plain_text(...)= @renderer.extract_plain_text(...)
        def render_paragraph(...) = @renderer.render_paragraph(...)
        def render_mixed_inline(...)= @renderer.render_mixed_inline(...)
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
        def render_liquid(...) = @renderer.render_liquid(...)
        def render_note_children(...) = @renderer.render_note_children(...)
        def render_simple_children(...) = @renderer.render_simple_children(...)
        def render_full_block_children(...) = @renderer.render_full_block_children(...)
      end

      def renderer_context
        @renderer_context ||= RendererContext.new(self)
      end

      def toc_entries
        @toc_entries
      end

      attr_writer :document, :theme

      def generate_full_document(document, **)
        @document = document
        validate_presentation_xml!

        body = render(@document) || ""

        assemble_document(body)
      end

      # --- Flavor configuration hooks ---

      FLAVOR_MAP = {
        "IsoDocument" => :iso,
        "IecDocument" => :iec,
        "IeeeDocument" => :ieee,
        "IetfDocument" => :ietf,
        "ItuDocument" => :itu,
        "IhoDocument" => :iho,
        "BipmDocument" => :bipm,
        "OgcDocument" => :ogc,
        "OimlDocument" => :oiml,
        "CcDocument" => :cc,
        "IccDocument" => :icc,
        "RiboseDocument" => :ribose,
        "PdfaDocument" => :pdfa,
      }.freeze

      def theme
        @theme ||= resolve_theme
      end

      def resolve_theme
        flavor = flavor_name
        flavor ? Theme.load(flavor) : Theme.new
      end

      def flavor_name
        return nil unless defined?(@document) && @document

        @document.class.name&.split("::")&.detect do |ns|
          FLAVOR_MAP.key?(ns)
        end&.then { |ns| FLAVOR_MAP[ns] }
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

      def load_logo_svg(filename, height: 32)
        path = theme.resolve_asset(filename) || File.join(LOGO_DIR, filename)
        return nil unless File.exist?(path)

        svg = File.read(path)
        svg = svg.sub(/\A<\?xml[^?]*\?>\s*/, "")
        svg = svg.sub(/\A\s*<!--.*?-->\s*/m, "")
        svg = svg.sub(/<svg\s/, '<svg class="header-logo" ')
        svg = if svg.match?(/<svg[^>]*\sheight="[^"]*"/)
                svg.sub(/(<svg[^>]*?)(\sheight="[^"]*")/,
                        "\\1 height=\"#{height}\"")
              else
                svg.sub(/(<svg\b)/, "\\1 height=\"#{height}\"")
              end
        svg.sub(/(<svg[^>]*?)\swidth="[^"]*"/, '\1')
      rescue StandardError
        nil
      end

      def build_footer
        mn_logo = load_logo_svg(METANORMA_LOGO, height: 20)
        render_liquid("_footer.html.liquid", {
                        "mn_logo" => mn_logo,
                        "generated_at" => Time.now.strftime("%Y-%m-%d %H:%M"),
                      })
      end

      # --- ToC generation ---

      def build_toc_html(entries)
        entry_drops = entries.map { |e| Drops::TocEntryDrop.new(e) }
        figure_drops = @figure_entries.map { |f| Drops::FigureListEntryDrop.new(f) }
        table_drops = @table_entries.map { |t| Drops::FigureListEntryDrop.new(t) }
        has_special_lists = !@figure_entries.empty? || !@table_entries.empty?

        render_liquid("_toc.html.liquid", {
                        "entries" => entry_drops,
                        "figures" => figure_drops,
                        "tables" => table_drops,
                        "has_special_lists" => has_special_lists,
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

      # --- Validation ---

      def validate_presentation_xml!
        has_presentation = check_presentation_markers(@document)
        return if has_presentation

        raise ArgumentError,
              "HTML generation requires Presentation XML input. " \
              "Semantic XML does not contain formatting data needed for HTML. " \
              "Use a '.presentation.xml' file instead."
      end

      def check_presentation_markers(node)
        return false unless node
        return false if node.is_a?(String)

        if node.is_a?(Lutaml::Model::Serializable)
          node_attrs = node.class.attributes
          if node_attrs.key?(:type) && node.type == "presentation"
            return true
          end
          if node_attrs.key?(:fmt_title) && node.fmt_title
            return true
          end
          if node_attrs.key?(:displayorder) && node.displayorder
            return true
          end

          %i[preface sections annex bibliography].each do |attr|
            next unless node_attrs.key?(attr)

            val = node.public_send(attr)
            next unless val

            Array(val).each { |v| return true if check_presentation_markers(v) }
          end

          node.each_mixed_content do |child|
            next if child.is_a?(String)
            return true if check_presentation_markers(child)
          end
        end

        false
      end

      # --- Metadata extraction ---

      def language
        bibdata = @document.bibdata
        return "en" unless bibdata

        langs = bibdata.language
        if langs && !langs.empty?
          lang = langs.find { |l| l.current == "true" } || langs.first
          lang.value || lang.to_s
        else
          "en"
        end
      end

      def html_title
        extract_display_title(@document.bibdata) || "Document"
      end

      def extract_display_title(bibdata)
        return nil unless bibdata

        title = bibdata.title_for("en") if bibdata.is_a?(Metanorma::Document::Components::BibData::BibData)
        return title.to_s if title && !title.to_s.empty?

        titles = safe_attr(bibdata, :title)
        return nil unless titles && !titles.is_a?(String) && !titles.empty?

        en = titles.find { |t| safe_attr(t, :language) == "en" }
        found = en || titles.first
        extract_text_value(found).to_s
      end

      def extract_primary_doc_id
        bibdata = @document.bibdata
        return nil unless bibdata

        identifiers = bibdata.doc_identifier
        return nil unless identifiers && !identifiers.empty?

        first_id = identifiers.first
        text = if first_id.is_a?(String)
                 first_id
               elsif first_id.is_a?(Lutaml::Model::Serializable)
                 Array(first_id.value).join
               else
                 first_id.to_s
               end
        text.strip.empty? ? nil : text.strip
      end

      # --- Registration helpers ---

      def register_toc_entry(id:, level:, text:)
        @toc_entries << { id: id, level: level, text: text }
      end

      def register_figure_entry(id:, text:)
        @figure_entries << { id: id, text: text }
      end

      def figure_entries
        @figure_entries
      end

      def register_table_entry(id:, text:)
        @table_entries << { id: id, text: text }
      end

      def extract_plain_text(node)
        return node.to_s if node.is_a?(String)
        return extract_text_value(node).to_s unless node.is_a?(Lutaml::Model::Serializable)

        parts = []
        xml_mapping = node.class.mappings_for(:xml, node.lutaml_register)

        if node.element_order.is_a?(Array) && xml_mapping
          element_to_attr = {}
          xml_mapping.mapping_elements_hash.each_value do |rule_or_array|
            Array(rule_or_array).each do |rule|
              element_to_attr[rule.name.to_s] = rule.to
            end
          end

          indices = Hash.new(0)
          node.element_order.each do |el|
            next unless el.is_a?(Lutaml::Xml::Element)

            if el.text?
              parts << el.text_content.to_s
            elsif el.name == "tab"
              parts << " "
            elsif el.name == "br"
              parts << " "
            elsif el.element?
              attr_name = element_to_attr[el.name]
              if attr_name
                coll = node.public_send(attr_name)
                obj = if coll.is_a?(Array)
                        idx = indices[attr_name]
                        indices[attr_name] += 1
                        coll[idx]
                      else
                        coll
                      end
                text = extract_plain_text(obj)
                parts << (text.empty? ? " " : text)
              elsif el.name == "span"
                parts << " "
              end
            end
          end
        end

        if parts.join.strip.empty?
          t = safe_attr(node, :text)
          parts << (t.is_a?(Array) ? t.join : t.to_s) if t
        end

        parts.join.strip.gsub(" ", " ")
      end

      # --- Dispatch ---

      def render(node, **)
        return escape_html(node) if node.is_a?(String)

        method = lookup_dispatch(node.class, :render_registry)
        method ? public_send(method, node, **) : ""
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
      register_inline_render Metanorma::Document::Components::Inline::FmtNameElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtTitleElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtXrefLabelElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtFnLabelElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtConceptElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtAnnotationBodyElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::VariantTitleElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::LocalizedStringElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::TitleWithAnnotationElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::BiblioTagElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::NameWithIdElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::DisplayTextElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtFnBodyElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtPreferredElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtDefinitionElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtTermsourceElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtAdmittedElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtIdentifierElement,
                             :render_mixed_inline
      register_inline_render Metanorma::Document::Components::Inline::FmtSourcecodeElement,
                             :render_mixed_inline

      def lookup_dispatch(type_class, registry_method)
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
      def render_mixed_content_in_order(node) = @inline_renderer.render_mixed_content_in_order(node)

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
      rescue NoMethodError
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
      rescue StandardError
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

      def extract_text_value(val)
        return nil if val.nil?
        return val if val.is_a?(String)

        if val.is_a?(Array)
          val.map { |v| extract_text_value(v) }.join
        elsif val.is_a?(Lutaml::Model::Serializable)
          c = safe_attr(val, :content)
          if c && !c.equal?(val)
            extract_text_value(c)
          else
            t = safe_attr(val, :text)
            if t
              extract_text_value(t)
            else
              v = safe_attr(val, :value)
              if v
                extract_text_value(v)
              else
                val.to_s
              end
            end
          end
        else
          val.to_s
        end
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
