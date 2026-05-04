# frozen_string_literal: true

require "liquid"
require "nokogiri"
require_relative "drops/footnote_drop"

module Metanorma
  module Html
    TEMPLATES_ROOT = File.join(__dir__, "templates")

    Liquid::Environment.default.file_system = Liquid::LocalFileSystem.new(TEMPLATES_ROOT, "_%s.html.liquid")

    # Renders BasicDocument components to HTML.
    # Subclassed by StandardRenderer and flavor-specific renderers.
    # Owns the full HTML document generation pipeline: body content, header,
    # footer, ToC sidebar, CSS (via Theme), and JavaScript.
    class BaseRenderer
      LOGO_DIR = File.expand_path("../../../data/logos", __dir__)

      # Map legacy XML class names to clean, semantic names.
      CLASS_MAP = {
        "zzSTDTitle1" => "doc-title",
        "coverpage_docnumber" => "cover-doc-id",
        "coverpage_docstage" => "cover-stage",
        "doctitle-en" => "cover-title",
        "ForewordTitle" => "foreword-title",
        "IntroTitle" => "intro-title",
        "Annex" => "annex-title",
        "Section3" => "section-sub",
        "TermNum" => "term-number",
        "Terms" => "term-name",
        "DeprecatedTerms" => "term-deprecated",
        "domain" => "term-domain",
        "boldtitle" => "bold-title",
        "note_label" => "note-label",
        "termnote_label" => "term-note-label",
        "example_label" => "example-label",
        "stddocNumber" => "std-doc-number",
        "stdyear" => "std-year",
        "sourcecode-name" => "code-name",
        "fmt-caption-label" => "caption-label",
        "fmt-autonum-delim" => "autonum-delim",
        "fmt-element-name" => "element-name",
        "fmt-caption-delim" => "caption-delim",
        "smallcap" => "small-caps",
        "obligation" => "obligation-text",
        "tableblock" => "table-block",
        "Biblio" => "biblio-entry",
        "Note" => "note-block",
        "source" => "term-source",
        "nonboldtitle" => "doc-subtitle",
        "stddocPartNumber" => "doc-part-number",
        "stddocTitle" => "doc-part-title",
        "std_publisher" => "doc-publisher",
        "stdpublisher" => "doc-publisher-name",
        "fmt-xref-label" => "xref-label",
      }.freeze

      METANORMA_LOGO = "metanorma-logo.svg"

      def initialize
        @output = +""
        @toc_entries = []
        @figure_entries = []
        @table_entries = []
        @index_term_collector = Component::IndexTermCollector.new
        @footnote_collector = Component::FootnoteCollector.new
        @current_section_id = nil
        @current_section_number = nil
      end

      # --- Public API ---

      def to_html
        @output
      end

      def toc_entries
        @toc_entries
      end

      # Generate a complete HTML document from a presentation XML document.
      def generate_full_document(document)
        @document = document
        validate_presentation_xml!

        # First pass: render body content (collects ToC entries as side effect)
        render(@document)
        body = @output

        assemble_document(body)
      end

      # --- Flavor configuration hooks (override in subclasses) ---

      def theme
        @theme ||= Theme.new
      end

      def flavor_publishers(_doc_id)
        []
      end

      def flavor_publisher_name
        pubs = flavor_publishers(extract_primary_doc_id)
        pubs.empty? ? nil : pubs.join("/")
      end

      # Map of publisher name => logo filename. Override in flavor renderers.
      def publisher_logo_map
        {}
      end

      def flavor_font_url
        theme.font_url
      end

      # --- Document Assembly ---

      TEMPLATE_CACHE = Hash.new { |h, k| h[k] = Liquid::Template.parse(File.read(k)) }

      def render_liquid(template_name, assigns)
        template_path = File.join(TEMPLATES_ROOT, template_name)
        template = TEMPLATE_CACHE[template_path]
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
        raw = html_title.to_s.split(" — ").first.to_s.gsub(/<[^>]+>/, "")
        raw.length > 60 ? raw[0, 57] + "..." : raw
      end

      # Reader controls — kept for backward compat with flavor renderers
      def build_reader_controls
        ""
      end

      def build_publisher_logos
        publishers = flavor_publishers(extract_primary_doc_id)
        logo_map = publisher_logo_map
        return "" if publishers.empty? && logo_map.empty?

        # Use flavor-declared publishers; fall back to logo map keys
        display_pubs = publishers.empty? ? logo_map.keys : publishers

        display_pubs.filter_map do |pub|
          filename = logo_map[pub]
          next unless filename

          svg = load_logo_svg(filename, height: 26)
          next unless svg

          "<span class=\"brand-logo\" aria-label=\"#{pub} logo\">#{svg}</span>"
        end.join("\n")
      end

      def detect_publishers
        flavor_publishers(extract_primary_doc_id)
      end

      def load_logo_svg(filename, height: 32)
        path = File.join(LOGO_DIR, filename)
        return nil unless File.exist?(path)

        svg = File.read(path)
        svg = svg.sub(/\A<\?xml[^?]*\?>\s*/, "")
        svg = svg.sub(/\A\s*<!--.*?-->\s*/m, "")
        svg = svg.sub(/<path[^>]*style="fill:#e3000f[^"]*"[^>]*\/>/, "")
        svg = svg.sub(/<svg\s/, '<svg class="header-logo" ')
        if svg.match?(/<svg[^>]*\sheight="[^"]*"/)
          svg = svg.sub(/(<svg[^>]*?)(\sheight="[^"]*")/, "\\1 height=\"#{height}\"")
        else
          svg = svg.sub(/(<svg\b)/, "\\1 height=\"#{height}\"")
        end
        svg = svg.sub(/(<svg[^>]*?)\swidth="[^"]*"/, '\1')
        svg
      rescue StandardError
        nil
      end

      def build_footer
        mn_logo = load_logo_svg(METANORMA_LOGO, height: 20)
        render_liquid("_footer.html.liquid", {
          "mn_logo" => mn_logo,
          "generated_at" => Time.now.strftime('%Y-%m-%d %H:%M'),
        })
      end

      # --- ToC generation ---

      def build_toc_html(entries)
        top_lines = []
        main_lines = if entries.empty?
                       ["<li class=\"toc-empty\">No entries</li>"]
                     else
                       entries.map { |e|
                         id = e[:id].to_s
                         text = escape_html(e[:text].to_s)
                         lvl = e[:level]
                         "<li class=\"toc-level-#{lvl}\"><a href=\"##{id}\" class=\"toc-link\" data-target=\"#{id}\">#{text}</a></li>"
                       }
                     end

        # List of Figures — at top of sidebar
        unless @figure_entries.empty?
          top_lines << "<li class=\"toc-list-header\" data-list=\"figures\"><button class=\"toc-list-toggle\" aria-expanded=\"false\"><svg width=\"14\" height=\"14\" viewBox=\"0 0 16 16\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.5\"><rect x=\"1\" y=\"2\" width=\"14\" height=\"12\" rx=\"1\"/><circle cx=\"5\" cy=\"6.5\" r=\"1.5\"/><path d=\"M1 12l4-4 2 2 3-3 5 5\"/></svg> Figures <span class=\"toc-list-count\">(#{@figure_entries.size})</span></button></li>"
          @figure_entries.each { |f|
            id = f[:id].to_s
            text = escape_html(f[:text].to_s)
            top_lines << "<li class=\"toc-list-item toc-figures\" style=\"display:none\"><a href=\"##{id}\" class=\"toc-link\" data-target=\"#{id}\">#{text}</a></li>"
          }
        end

        # List of Tables — at top of sidebar
        unless @table_entries.empty?
          top_lines << "<li class=\"toc-list-header\" data-list=\"tables\"><button class=\"toc-list-toggle\" aria-expanded=\"false\"><svg width=\"14\" height=\"14\" viewBox=\"0 0 16 16\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.5\"><rect x=\"1\" y=\"2\" width=\"14\" height=\"12\" rx=\"1\"/><line x1=\"1\" y1=\"6\" x2=\"15\" y2=\"6\"/><line x1=\"1\" y1=\"10\" x2=\"15\" y2=\"10\"/><line x1=\"7\" y1=\"2\" x2=\"7\" y2=\"14\"/></svg> Tables <span class=\"toc-list-count\">(#{@table_entries.size})</span></button></li>"
          @table_entries.each { |t|
            id = t[:id].to_s
            text = escape_html(t[:text].to_s)
            top_lines << "<li class=\"toc-list-item toc-tables\" style=\"display:none\"><a href=\"##{id}\" class=\"toc-link\" data-target=\"#{id}\">#{text}</a></li>"
          }
        end

        top_lines << "<li class=\"toc-divider\"></li>" unless top_lines.empty?

        (top_lines + main_lines).join("\n")
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
        "#{theme.to_css_root}\n#{css}\n#{theme.to_css_extras}"
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

        if node.is_a?(Metanorma::Document::Root) && node.type == "presentation"
          return true
        end

        if node.is_a?(Lutaml::Model::Serializable)
          return true if (node.public_send(:fmt_title) rescue nil)
          return true if (node.public_send(:displayorder) rescue nil)

          %i[preface sections annex bibliography].each do |attr|
            val = node.public_send(attr) rescue nil
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
        bibdata = @document.bibdata
        return "Document" unless bibdata

        titles = bibdata.titles
        if titles
          title = bibdata.title_for("en")
          title.to_s
        else
          "Document"
        end
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

      # --- CSS loader ---

      def register_toc_entry(id:, level:, text:)
        @toc_entries << { id: id, level: level, text: text }
      end

      def register_figure_entry(id:, text:)
        @figure_entries << { id: id, text: text }
      end

      def register_table_entry(id:, text:)
        @table_entries << { id: id, text: text }
      end

      attr_reader :index_term_collector, :footnote_collector

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
              parts << "\u00A0\u00A0"
            elsif el.name == "br"
              parts << " "
            elsif el.element?
              attr_name = element_to_attr[el.name]
              next unless attr_name

              coll = node.public_send(attr_name)
              obj = if coll.is_a?(Array)
                      idx = indices[attr_name]
                      indices[attr_name] += 1
                      coll[idx]
                    else
                      coll
                    end
              parts << extract_plain_text(obj) if obj
            end
          end
        end

        # Fallback: try .text
        if parts.join.strip.empty?
          t = safe_attr(node, :text)
          parts << (t.is_a?(Array) ? t.join : t.to_s) if t
        end

        parts.join.strip.gsub(/\u00A0/, " ")
      end

      # Dispatch to the appropriate render method based on node class.
      def render(node, **opts)
        case node
        when Metanorma::Document::Components::Paragraphs::ParagraphBlock
          render_paragraph(node, **opts)
        when Metanorma::Document::Components::Tables::TableBlock
          render_table(node, **opts)
        when Metanorma::Document::Components::Lists::UnorderedList
          render_unordered_list(node, **opts)
        when Metanorma::Document::Components::Lists::OrderedList
          render_ordered_list(node, **opts)
        when Metanorma::Document::Components::Lists::DefinitionList
          render_definition_list(node, **opts)
        when Metanorma::Document::Components::AncillaryBlocks::FigureBlock
          render_figure(node, **opts)
        when Metanorma::Document::Components::Blocks::NoteBlock
          render_note(node, **opts)
        when Metanorma::Document::Components::AncillaryBlocks::ExampleBlock
          render_example(node, **opts)
        when Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
          render_sourcecode(node, **opts)
        when Metanorma::Document::Components::AncillaryBlocks::FormulaBlock
          render_formula(node, **opts)
        when Metanorma::Document::Components::MultiParagraph::QuoteBlock
          render_quote(node, **opts)
        when Metanorma::Document::Components::MultiParagraph::AdmonitionBlock
          render_admonition(node, **opts)
        when Metanorma::Document::Components::Sections::HierarchicalSection
          render_hierarchical_section(node, **opts)
        when Metanorma::Document::Components::Sections::BasicSection
          render_basic_section(node, **opts)
        when Metanorma::Document::Components::Sections::ContentSection
          render_content_section(node, **opts)
        when Metanorma::Document::Components::EmptyElements::PageBreakElement
          ""
        when Metanorma::Document::Components::IdElements::Bookmark
          render_bookmark(node)
        when Metanorma::Document::Components::Inline::SemxElement
          render_semx_content(node)
        when String
          escape_html(node)
        else
          ""
        end
      end

      private

      # --- Block-level rendering ---

      def render_paragraph(p, **_opts)
        attrs = element_attrs(id: safe_attr(p, :id), class: safe_attr(p, :class_attr), style: alignment_style(safe_attr(p, :alignment)))
        tag("p", attrs) { render_mixed_inline(p) }
      end

      def render_table(table, **_opts)
        attrs = element_attrs(id: safe_attr(table, :id), class: "table-block")
        table_id = safe_attr(table, :id)
        name_el = safe_attr(table, :fmt_name) || safe_attr(table, :name)
        if table_id && name_el
          register_table_entry(id: table_id, text: extract_plain_text(name_el))
        end
        col_count = table_column_count(table)
        @output << "<div class=\"table-scroll-wrapper\">"
        tag("table", attrs) do
          name_el = safe_attr(table, :fmt_name) || safe_attr(table, :name)
          if name_el
            @output << "<caption>"
            render_inline_element(name_el)
            @output << "</caption>"
          end
          @output << "<colgroup>" if table.colgroup
          render_table_colgroup(table.colgroup) if table.colgroup
          @output << "</colgroup>" if table.colgroup
          render_table_section(table.thead, "thead") if table.thead
          render_table_section(table.tbody, "tbody") if table.tbody
          if table.tfoot || (table.note && !table.note.empty?)
            @output << "<tfoot>"
            render_table_section_rows(table.tfoot) if table.tfoot
            if table.note && !table.note.empty?
              @output << "<tr><td colspan=\"#{col_count}\" class=\"table-notes\">"
              table.note.each { |n| render_note(n) }
              @output << "</td></tr>"
            end
            @output << "</tfoot>"
          end
        end
        @output << "</div>"
      end

      def table_column_count(table)
        if table.colgroup&.col && !table.colgroup.col.empty?
          return table.colgroup.col.size
        end
        # Walk all rows to find max column count, accounting for colspan
        max_cols = 0
        [:thead, :tbody, :tfoot].each do |section|
          sec = table.public_send(section)
          next unless sec&.tr
          sec.tr.each do |tr|
            cols = 0
            Array(tr.th).each { |th| cols += (th.colspan && th.colspan > 1) ? th.colspan : 1 }
            Array(tr.td).each { |td| cols += (td.colspan && td.colspan > 1) ? td.colspan : 1 }
            max_cols = cols if cols > max_cols
          end
        end
        max_cols > 0 ? max_cols : 1
      end

      def render_table_colgroup(colgroup)
        colgroup.col&.each do |col|
          attrs = element_attrs(style: col.width ? "width: #{col.width}" : nil)
          @output << "<col#{attrs}>"
        end
      end

      def render_table_section(section, tag_name)
        @output << "<#{tag_name}>"
        render_table_section_rows(section)
        @output << "</#{tag_name}>"
      end

      def render_table_section_rows(section)
        section.tr&.each do |tr|
          @output << "<tr>"
          walked = walk_ordered(tr) do |type, obj|
            next unless type == :element
            render_table_cell(obj)
          end
          unless walked
            Array(tr.th).each { |th| render_table_cell(th, "th") }
            Array(tr.td).each { |td| render_table_cell(td, "td") }
          end
          @output << "</tr>"
        end
      end

      def render_unordered_list(ul, **_opts)
        attrs = element_attrs(id: safe_attr(ul, :id), class: safe_attr(ul, :class_attr))
        tag("ul", attrs) do
          ul.listitem&.each { |li| render_list_item(li) }
        end
      end

      def render_table_cell(cell, force_tag = nil)
        tag_name = force_tag || (cell.is_a?(Metanorma::Document::Components::Tables::HeaderTableCell) ? "th" : "td")
        attrs = element_attrs(
          colspan: safe_attr(cell, :colspan),
          rowspan: safe_attr(cell, :rowspan),
          align: safe_attr(cell, :alignment),
          valign: safe_attr(cell, :vertical_alignment),
        )
        @output << "<#{tag_name}#{attrs}>"
        render_cell_content(cell)
        @output << "</#{tag_name}>"
      end

      def render_ordered_list(ol, **_opts)
        attrs = element_attrs(id: safe_attr(ol, :id), class: safe_attr(ol, :class_attr), start: safe_attr(ol, :start), type: safe_attr(ol, :type_attr))
        tag("ol", attrs) do
          ol.listitem&.each { |li| render_list_item(li) }
        end
      end

      def render_list_item(li)
        li_id = safe_attr(li, :id)
        attrs = li_id ? %( id="#{escape_html(li_id)}") : ""
        @output << "<li#{attrs}>"
        render_mixed_content_in_order(li)
        @output << "</li>"
      end

      # Render all children of a mixed-content node in document order,
      # dispatching block elements to their render methods.
      def render_mixed_content_in_order(node)
        node.each_mixed_content do |child|
          case child
          when String
            @output << escape_html(child)
          else
            if block_element?(child)
              render(child)
            else
              render_inline_element(child)
            end
          end
        end
      end

      # Collect all renderable children from a node in document order,
      # sorted by displayorder when available. Uses walk_ordered to traverse
      # element_order, and also gathers typed attributes that may not appear
      # in element_order (e.g. terms, definitions on section models).
      def collect_ordered_children(section)
        children = []

        walk_ordered(section) do |type, obj|
          next if type == :text || type == :tab
          children << obj
        end

        # Gather typed attributes that may not appear in element_order
        supplementary_attrs = %i[terms definitions]
        supplementary_attrs.each do |attr|
          val = safe_attr(section, attr)
          next if val.nil?
          Array(val).each do |v|
            children << v unless children.include?(v)
          end
        end

        children.compact!
        sort_by_displayorder(children)
      end

      # Render children of a section in displayorder, skipping title elements.
      def render_ordered_content(section, level = 1)
        children = collect_ordered_children(section)
        children.each do |node|
          next if node.is_a?(String)
          next if is_title_element?(node, section)

          render(node, level: level + 1)
        end
      end

      def sort_by_displayorder(children)
        children.sort_by do |node|
          order = node.displayorder rescue nil
          order &&= order.to_i
          order || Float::INFINITY
        end
      end

      def render_definition_list(dl, **_opts)
        attrs = element_attrs(id: safe_attr(dl, :id))
        tag("dl", attrs) do
          dl.dt&.each_with_index do |dt, i|
            @output << "<dt>"
            render_mixed_inline(dt)
            @output << "</dt>"
            dd = dl.dd&.[](i)
            if dd
              @output << "<dd>"
              render_mixed_inline(dd)
              @output << "</dd>"
            end
          end
        end
      end

      def render_figure(figure, **_opts)
        attrs = element_attrs(id: safe_attr(figure, :id), class: "figure")
        fig_id = safe_attr(figure, :id)
        fig_name = safe_attr(figure, :fmt_name) || safe_attr(figure, :name)
        if fig_id && fig_name
          register_figure_entry(id: fig_id, text: extract_plain_text(fig_name))
        end
        tag("figure", attrs) do
          if figure.image
            render_image(figure.image)
          elsif safe_attr(figure, :source)
            @output << %(<img src="#{escape_html(figure.source)}" />)
          end
          render_video(figure.video) if safe_attr(figure, :video)
          render_audio(figure.audio) if safe_attr(figure, :audio)
          figure.figure&.each { |sub| render_figure(sub) }
          if safe_attr(figure, :name) || safe_attr(figure, :fmt_name)
            @output << "<figcaption>"
            render_inline_element(safe_attr(figure, :fmt_name) || figure.name)
            @output << "</figcaption>"
          end
          safe_attr(figure, :note)&.each { |n| render_note(n) }
          safe_attr(figure, :dl)&.then { |dl| render_definition_list(dl) }
        end
      end

      def render_image(image)
        src_val = safe_attr(image, :src) || safe_attr(image, :source)
        attrs = element_attrs(
          id: safe_attr(image, :id),
          src: src_val,
          alt: safe_attr(image, :alt),
          height: safe_attr(image, :height),
          width: safe_attr(image, :width),
        )
        @output << "<img#{attrs} />"
      end

      def render_video(video)
        attrs = element_attrs(
          id: safe_attr(video, :id),
          src: safe_attr(video, :src),
        )
        @output << "<video#{attrs} controls></video>"
      end

      def render_audio(audio)
        attrs = element_attrs(
          id: safe_attr(audio, :id),
          src: safe_attr(audio, :src),
        )
        @output << "<audio#{attrs} controls></audio>"
      end

      def render_note(note, **_opts)
        attrs = element_attrs(id: safe_attr(note, :id), class: "note-block")
        tag("div", attrs) do
          label = extract_block_label(note, "NOTE")
          @output << %(<span class="note-label">#{escape_html(label)}</span>&nbsp;)
          if note.content && !note.content.empty?
            note.content.each { |para| render_paragraph(para) }
          else
            render_mixed_inline(note)
          end
          note.ul&.each { |ul| render_unordered_list(ul) }
          note.ol&.each { |ol| render_ordered_list(ol) }
          note.dl&.then { |dl| render_definition_list(dl) }
        end
      end

      def render_example(example, **_opts)
        attrs = element_attrs(id: safe_attr(example, :id), class: "example")
        tag("div", attrs) do
          label = extract_block_label(example, "EXAMPLE")
          @output << %(<span class="example-label">#{escape_html(label)}</span>&nbsp;)
          if example.paragraphs && !example.paragraphs.empty?
            example.paragraphs.each { |para| render_paragraph(para) }
          end
          example.ul&.each { |ul| render_unordered_list(ul) }
          example.ol&.each { |ol| render_ordered_list(ol) }
          example.dl&.each { |dl| render_definition_list(dl) } if example.dl
          example.sourcecode&.each { |sc| render_sourcecode(sc) }
          example.table&.each { |t| render_table(t) }
          example.figure&.each { |f| render_figure(f) }
          example.quote&.each { |q| render_quote(q) }
          example.formula&.each { |f| render_formula(f) }
        end
      end

      def render_sourcecode(sc, **_opts)
        attrs = element_attrs(id: safe_attr(sc, :id), class: "sourcecode")
        lang = safe_attr(sc, :lang)
        tag("div", attrs) do
          if sc.name
            @output << "<p class=\"code-name\">"
            render_inline_element(sc.name)
            @output << "</p>"
          end
          code_attrs = lang ? %( lang="#{escape_html(lang)}") : ""
          @output << "<pre><code#{code_attrs}>"
          # Use body.content if available, else content, else text
          code_text = if sc.body && sc.body.content
                        sc.body.content
                      elsif sc.content
                        sc.content
                      else
                        ""
                      end
          # body.content from map_all_content may contain pre-escaped HTML
          # entities (&lt; etc); decode first to get raw text, then escape
          # for HTML output.
          raw_text = code_text.gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&").gsub("&quot;", "\"")
          @output << escape_html(raw_text)
          @output << "</code></pre>"
        end
      end

      def render_formula(formula, **_opts)
        attrs = element_attrs(id: safe_attr(formula, :id), class: "formula")
        tag("div", attrs) do
          @output << render_stem_content(formula.stem) if formula.stem

          # Render "where" clause from key element (non-presentation XML)
          if formula.key
            if formula.key.dl
              @output << "<p class=\"formula-where\">where</p>"
              render_definition_list(formula.key.dl)
            end
            formula.key.p&.each { |para| render_paragraph(para) }
          end

          formula.dl&.then { |dl| render_definition_list(dl) }

          name_el = safe_attr(formula, :fmt_name) || safe_attr(formula, :name)
          if name_el
            @output << "<span class=\"formula-number\">"
            render_inline_element(name_el)
            @output << "</span>"
          end
        end
      end

      def render_quote(quote, **_opts)
        attrs = element_attrs(id: safe_attr(quote, :id), class: "quote")
        tag("blockquote", attrs) do
          quote.paragraphs&.each { |para| render_paragraph(para) }
          quote.ul&.each { |ul| render_unordered_list(ul) }
          quote.ol&.each { |ol| render_ordered_list(ol) }
          if quote.attribution
            @output << "<footer>"
            render_mixed_inline(quote.attribution)
            @output << "</footer>"
          end
        end
      end

      def render_admonition(admonition, **_opts)
        type = safe_attr(admonition, :type) || "note"
        attrs = element_attrs(id: safe_attr(admonition, :id), class: "admonition #{type}")
        tag("div", attrs) do
          @output << "<p class=\"admonition-title\">#{escape_html(type.capitalize)}</p>"
          admonition.paragraphs&.each { |para| render_paragraph(para) }
        end
      end

      def render_bookmark(bookmark)
        @output << %(<a id="#{escape_html(safe_attr(bookmark, :id).to_s)}"></a>)
      end

      # --- Section rendering ---

      def render_basic_section(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_section_title(section, level)
          section.blocks&.each { |block| render(block) }
          section.notes&.each { |note| render_note(note) }
        end
      end

      def render_hierarchical_section(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_section_title(section, level)
          render_section_content(section, level)
          section.subsections&.each { |sub| render(sub, level: level + 1) }
        end
      end

      def render_content_section(section, level: 1, **_opts)
        render_hierarchical_section(section, level: level, **_opts)
      end

      def render_section_title(section, level)
        titles = section.title
        return unless titles && !titles.empty?

        h = "h#{[[level, 6].min, 1].max}"
        title_text = extract_title_text(titles)
        @output << "<#{h}>#{escape_html(title_text)}</#{h}>"
      end

      def render_section_content(section, _level)
        section.blocks&.each { |block| render(block) }
        section.notes&.each { |note| render_note(note) }
      end

      # --- Inline content rendering ---

      # Walk element_order in document order, resolving each element to its
      # Ruby object via the XML mapping, and yielding (element_order_entry, resolved_object)
      # to the given block. Handles tab elements as nbsp. Skips elements not in the mapping.
      #
      # This is the single ordered-walk primitive used by all mixed content renderers:
      # - render_mixed_inline (inline-only)
      # - render_cell_content (mixed block/inline)
      # - render_semx_content (filtered display attrs only)
      def walk_ordered(node, allow_filter: nil)
        return false unless node.is_a?(Lutaml::Model::Serializable)
        return false unless node.element_order.is_a?(Array) && !node.element_order.empty?

        xml_mapping = node.class.mappings_for(:xml, node.lutaml_register)
        return false unless xml_mapping

        element_to_attr = {}
        xml_mapping.mapping_elements_hash.each_value do |rule_or_array|
          Array(rule_or_array).each do |rule|
            element_to_attr[rule.name] = rule.to
            element_to_attr[rule.name.to_s] = rule.to if rule.name.is_a?(Symbol)
          end
        end

        skip_indices = build_semx_skip_set(node)

        indices = Hash.new(0)

        node.element_order.each_with_index do |el, i|
          next if skip_indices.include?(i)

          if el.text?
            text = el.text_content
            yield :text, text if text && block_given?
          elsif el.element?
            # Handle <tab/> elements
            if el.name == "tab"
              yield :tab, nil if block_given?
              next
            end

            attr_name = element_to_attr[el.name]
            next unless attr_name

            # Apply optional filter (used by semx to skip semantic attrs)
            next if allow_filter && !allow_filter.include?(attr_name)

            coll = node.send(attr_name)
            obj = if coll.is_a?(Array)
                    idx = indices[attr_name]
                    indices[attr_name] += 1
                    coll[idx]
                  else
                    coll
                  end
            yield :element, obj if obj && block_given?
          end
        end
        true
      end

      # In presentation XML, semantic elements are followed by <semx> wrappers
      # or <fmt-*> display elements. Skip source elements to avoid duplicates.
      def build_semx_skip_set(node)
        skip_after = {
          "link" => "semx",
          "xref" => "semx",
          "eref" => "semx",
          "stem" => nil,
          "concept" => "fmt-concept",
          "refterm" => nil,
          "renderterm" => nil,
          "origin" => "semx",
        }
        skip = {}
        node.element_order.each_with_index do |el, i|
          next unless el.element?
          next_tag = skip_after[el.name]
          next unless next_tag

          next_el = node.element_order[i + 1]
          if next_tag.nil?
            skip[i] = true
          elsif next_el && next_el.element? && next_el.name == next_tag
            skip[i] = true
          end
        end
        skip
      end

      # Table cells can contain both block-level content (p, ul, ol, dl)
      # and inline content (text, em, strong, etc.) in document order.
      def render_cell_content(cell)
        walked = walk_ordered(cell) do |type, obj|
          case type
          when :text
            @output << escape_html(obj)
          when :tab
            @output << "\u00a0\u00a0"
          when :element
            if block_element?(obj)
              render(obj)
            else
              render_inline_element(obj)
            end
          end
        end
        unless walked
          render_mixed_content_in_order(cell)
        end
      end

      def render_mixed_inline(node)
        # Models using map_all_content (e.g. RawParagraph): raw XML in content
        if raw_content_node?(node)
          raw = node.content
          if raw.is_a?(String) && !raw.strip.empty?
            @output << render_raw_content(raw)
            return
          end
        end

        if node.is_a?(Lutaml::Model::Serializable) && node.element_order && !node.element_order.empty?
          render_ordered_inline(node)
        elsif node.is_a?(Lutaml::Model::Serializable)
          node.each_mixed_content do |child|
            case child
            when String
              @output << escape_html(child)
            else
              render_inline_element(child)
            end
          end
        else
          render_inline_collections(node)
        end
      end

      def raw_content_node?(node)
        node.is_a?(Metanorma::IsoDocument::RawParagraph)
      end

      # Iterate element_order directly, preserving whitespace text nodes
      # that each_mixed_content drops (it skips text where text.strip.empty?)
      def render_ordered_inline(node)
        walked = walk_ordered(node) do |type, obj|
          case type
          when :text
            @output << escape_html(obj)
          when :tab
            @output << "\u00a0\u00a0"
          when :element
            render_inline_element(obj)
          end
        end
        unless walked
          node.each_mixed_content do |child|
            case child
            when String
              @output << escape_html(child)
            else
              render_inline_element(child)
            end
          end
        end
      rescue StandardError
        node.each_mixed_content do |child|
          case child
          when String
            @output << escape_html(child)
          else
            render_inline_element(child)
          end
        end
      end

      def render_inline_element(element)
        return "" if element.nil?

        case element
        when String
          @output << escape_html(element)
        when Metanorma::Document::Components::Inline::EmRawElement
          render_inline_tag("em", element)
        when Metanorma::Document::Components::Inline::StrongRawElement
          render_inline_tag("strong", element)
        when Metanorma::Document::Components::Inline::TtElement
          render_inline_tag("tt", element)
        when Metanorma::Document::Components::Inline::SubElement
          render_inline_tag("sub", element)
        when Metanorma::Document::Components::Inline::SupElement
          render_inline_tag("sup", element)
        when Metanorma::Document::Components::Inline::SmallCapElement
          render_inline_tag("span", element, class: "small-caps")
        when Metanorma::Document::Components::TextElements::UnderlineElement
          render_inline_tag("u", element)
        when Metanorma::Document::Components::TextElements::StrikeElement
          render_inline_tag("s", element)
        when Metanorma::Document::Components::Inline::BrElement
          @output << "<br />"
        when Metanorma::Document::Components::Inline::TabElement
          @output << "\u00a0\u00a0"
        when Metanorma::Document::Components::Inline::LinkElement
          render_link(element)
        when Metanorma::Document::Components::Inline::XrefElement
          # Source element — skip; rendered via fmt-xref in semx wrapper
          nil
        when Metanorma::Document::Components::Inline::ErefElement
          # Source element — skip; rendered via fmt-xref in semx wrapper
          nil
        when Metanorma::Document::Components::Inline::SpanElement
          attrs = element_attrs(style: safe_attr(element, :style), class: safe_attr(element, :class_attr))
          tag("span", attrs) { render_mixed_inline(element) }
        when Metanorma::Document::Components::Inline::FnElement
          render_fn(element)
        when Metanorma::Document::Components::Inline::ConceptElement
          render_concept(element)
        when Metanorma::Document::Components::Inline::StemInlineElement
          # Source element — skip; rendered via FmtStemElement
          nil
        when Metanorma::Document::Components::TextElements::StemElement
          @output << render_stem_content(element)
        when Metanorma::Document::Components::Inline::SemxElement
          render_semx_content(element)
        when Metanorma::Document::Components::Inline::FmtNameElement,
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
             Metanorma::Document::Components::Inline::FmtSourcecodeElement
          render_mixed_inline(element)
        when Metanorma::Document::Components::Inline::FmtXrefElement
          target = safe_attr(element, :target) || safe_attr(element, :to_attr)
          if target
            attrs = element_attrs(href: "##{escape_html(target)}", class: "xref")
            tag("a", attrs) { render_mixed_inline(element) }
          else
            render_mixed_inline(element)
          end
        when Metanorma::Document::Components::Inline::FmtStemElement
          render_fmt_stem(element)
        when Metanorma::Document::Components::Inline::CommaElement,
             Metanorma::Document::Components::Inline::EnumCommaElement
          @output << ", "
        when Metanorma::Document::Components::IdElements::Bookmark
          render_bookmark(element)
        when Metanorma::Document::Components::IdElements::Image
          render_image(element)
        when Metanorma::Document::Components::Inline::MathElement
          @output << element.content.to_s
        when Metanorma::Document::Components::Inline::AsciimathElement
          @output << %(<span class="stem">#{escape_html(Array(element.text).join)}</span>)
        when Metanorma::Document::Components::EmptyElements::IndexElement,
             Metanorma::Document::Components::ReferenceElements::IndexXrefElement
          collect_index_term(element)
          ""
        when Metanorma::Document::Components::Blocks::NoteBlock
          render_note(element)
        else
          # Attempt generic mixed content rendering for unknown inline types
          if element.is_a?(Lutaml::Model::Serializable) && element.mixed?
            render_mixed_inline(element)
          end
        end
      end

      def render_inline_collections(node)
        # Fallback: render text and inline collections sequentially
        texts = node.text
        if texts.is_a?(Array)
          texts.each do |t|
            if t.is_a?(Metanorma::Document::Components::Inline::MathElement)
              @output << t.content.to_s
            elsif t.is_a?(Metanorma::Document::Components::Inline::AsciimathElement)
              @output << %(<span class="stem">#{escape_html(Array(t.text).join)}</span>)
            else
              @output << escape_html(t.to_s)
            end
          end
        elsif texts.is_a?(String)
          @output << escape_html(texts)
        end

        inline_attrs = %i[em strong smallcap sub sup tt underline strike
                          xref eref link span stem concept fn br tab keyword
                          fmt_annotation_start fmt_annotation_end
                          fmt_stem fmt_fn_label fmt_concept
                          bookmark image semx fmt_xref_label]
        inline_attrs.each do |attr|
          values = safe_attr(node, attr)
          next if values.nil?

          Array(values).each { |v| render_inline_element(v) }
        end
      end

      # Render SemxElement display content only, skipping semantic linkage.
      # semx wraps both semantic data (origin, xref, source, etc.) and
      # display content (fmt-xref, span, strong, etc.). Only render display.
      def render_semx_content(element)
        display_attrs = %i[text fmt_xref fmt_link fmt_concept span strong em sup p semx
                           asciimath math sub_child tt_child br_child tab_child
                           stem_child figure_child formula_child sourcecode_child]
        label_stripped = false

        walked = walk_ordered(element, allow_filter: display_attrs) do |type, obj|
          case type
          when :text
            text = obj
            if !label_stripped
              text = deduplicate_semx_text(text, @output)
              label_stripped = true
            end
            @output << escape_html(text)
          when :element
            if obj.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
              render_paragraph(obj)
            else
              render_inline_element(obj)
            end
          end
        end

        unless walked
          display_attrs.each do |attr|
            val = safe_attr(element, attr)
            next if val.nil?
            if val.is_a?(Array)
              val.each do |v|
                if v.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
                  render_paragraph(v)
                else
                  render_inline_element(v)
                end
              end
            elsif val.is_a?(String)
              @output << escape_html(val)
            else
              render_inline_element(val)
            end
          end
        end
      end

      def deduplicate_semx_text(semx_text, output)
        first_word = semx_text[/\A\s*(\S+)/, 1]
        return semx_text unless first_word

        tail = output[-200..]
        return semx_text unless tail && tail.rstrip.end_with?(first_word)

        semx_text.sub(/\A\s*#{Regexp.escape(first_word)}\s*/, "")
      end

      def render_inline_tag(tag_name, element, **extra_attrs)
        tag(tag_name, element_attrs(**extra_attrs)) { render_mixed_inline(element) }
      end

      # Process raw XML content from map_all_content models (e.g. RawParagraph).
      # Strips source elements (xref, eref, stem) that have a following <semx>
      # wrapper, keeping only the semx display content.
      def render_raw_content(raw_xml)
        doc = Nokogiri::XML.fragment(raw_xml)
        # Convert fmt-link elements to HTML <a> tags before stripping wrappers
        doc.css("fmt-link").each do |el|
          target = el["target"] || el["href"]
          if target
            display_text = target.sub(/\Amailto:/, "")
            a = doc.document.create_element("a", display_text, "href" => target)
            el.replace(a)
          else
            el.replace(el.children)
          end
        end
        # Remove source elements that precede a <semx> sibling,
        # deduplicating any label text that appears in both the source
        # paragraph and the semx display content.
        doc.traverse do |node|
          next unless node.element?
          next unless %w[xref eref stem link].include?(node.name)
          next_sib = node.next_sibling
          while next_sib.is_a?(Nokogiri::XML::Text) && next_sib.text.strip.empty?
            next_sib = next_sib.next_sibling
          end
          next unless next_sib && next_sib.element? && next_sib.name == "semx"

          deduplicate_semx_label(node, next_sib)
          node.remove
        end
        # Strip presentation wrappers, keeping inner content
        %w[semx fmt-xref].each do |tag|
          doc.css(tag).each { |el| el.replace(el.children) }
        end
        doc.inner_html
      end

      def deduplicate_semx_label(source_node, semx_node)
        first_text = semx_node.children.find { |c| c.text? && !c.text.strip.empty? }
        return unless first_text

        semx_prefix = first_text.text[/\A(\s*\S+)/, 1]
        return unless semx_prefix && !semx_prefix.strip.empty?

        prev = source_node.previous_sibling
        return unless prev.is_a?(Nokogiri::XML::Text)

        label = semx_prefix.strip
        prev_text = prev.text.rstrip
        return unless prev_text.end_with?(label)

        prev.content = prev_text.sub(/#{Regexp.escape(label)}\s*\z/, "")
        first_text.content = first_text.text.sub(/\A\s*#{Regexp.escape(label)}\s*/, "")
      end

      def render_link(link)
        target = safe_attr(link, :target) || safe_attr(link, :href)
        attrs = element_attrs(href: target, id: safe_attr(link, :id), class: safe_attr(link, :class_attr))
        tag("a", attrs) do
          content = safe_attr(link, :content)
          if content && !Array(content).join.strip.empty?
            render_mixed_inline(link)
          else
            display_text = target.to_s.sub(/\Amailto:/, "")
            @output << escape_html(display_text)
          end
        end
      end

      def render_xref(xref)
        target = safe_attr(xref, :target) || safe_attr(xref, :to_attr)
        attrs = element_attrs(href: "##{escape_html(target)}", id: safe_attr(xref, :id), class: safe_attr(xref, :class_attr))
        tag("a", attrs) { render_mixed_inline(xref) }
      end

      def render_eref(eref)
        citeas = safe_attr(eref, :citeas)
        if citeas
          @output << escape_html(citeas)
        else
          render_mixed_inline(eref)
        end
      end

      def render_fn(fn)
        fn_id = safe_attr(fn, :id)
        number = @footnote_collector.register(fn)

        attrs = element_attrs(id: fn_id, class: "fn-marker")
        tag("span", attrs) do
          label = safe_attr(fn, :fn_label) || safe_attr(fn, :reference)
          if label
            @output << "<sup><a href=\"##{escape_html("footnote-#{number}")}\" " \
                       "class=\"fn-link\" id=\"#{escape_html("fnref-#{number}")}\">" \
                       "#{escape_html(label.to_s)}</a></sup>"
          end
        end
      end

      def render_concept(concept)
        render_mixed_inline(concept)
      end

      # --- Stem/math rendering ---

      def render_fmt_stem(fmt_stem)
        semx_items = Array(fmt_stem.semx)
        return if semx_items.empty?

        semx = semx_items.first
        math_items = Array(semx.math)
        ascii_items = Array(semx.asciimath)

        # Collect source formats for interactive copy dropdown
        source_formats = {}
        if ascii_items.any?
          ascii_text = ascii_items.map { |a| a.text.to_s.strip }.join
          source_formats["asciimath"] = ascii_text unless ascii_text.empty?
        end

        data_attrs = ""
        unless source_formats.empty?
          data_attrs = " data-stem-formats='#{escape_html(source_formats.to_json)}'"
        end

        if math_items.any?
          content = math_items.map { |m| m.content.to_s }.join
          unless content.empty?
            @output << "<span class=\"math-container\"#{data_attrs}>"
            @output << "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">#{content}</math>"
            @output << "</span>"
          end
        elsif ascii_items.any?
          # No MathML — render asciimath as fallback
          text = ascii_items.map { |a| a.text.to_s.strip }.join
          @output << "<span class=\"stem\"#{data_attrs}>#{escape_html(text)}</span>"
        end
      end

      def render_stem_content(stem)
        return "" if stem.nil?

        # StemInlineElement — source element, skip (rendered via FmtStemElement)
        if stem.is_a?(Metanorma::Document::Components::Inline::StemInlineElement)
          return ""
        end

        # FmtStemElement — already handled by render_fmt_stem
        if stem.is_a?(Metanorma::Document::Components::Inline::FmtStemElement)
          return ""
        end

        # TextElements::StemElement — block math (no fmt- counterpart for display formulas)
        if stem.is_a?(Metanorma::Document::Components::TextElements::StemElement)
          if stem.math
            begin
              return stem.math.to_xml
            rescue StandardError
              math_items = Array(stem.math)
              return math_items.map { |m| m.respond_to?(:content) ? m.content.to_s : m.to_s }.join
            end
          end
          if stem.asciimath
            text = extract_text_value(stem.asciimath)
            return %(<span class="stem">#{escape_html(text)}</span>)
          end
          if stem.latexmath
            text = extract_text_value(stem.latexmath)
            return %(<span class="stem">#{escape_html(text)}</span>)
          end
        end

        text = extract_text_value(stem)
        text.empty? ? "" : %(<span class="stem">#{escape_html(text)}</span>)
      end

      # --- Helper methods ---

      def tag(name, attrs_str)
        @output << "<#{name}#{attrs_str}>"
        yield
        @output << "</#{name}>"
      end

      def element_attrs(**attrs)
        parts = []
        attrs.each do |k, v|
          next if v.nil? || v == false || (v.is_a?(String) && v.empty?)

          val = k == :class ? translate_class(v.to_s) : v.to_s
          parts << %( #{k}="#{escape_html(val)}")
        end
        parts.join
      end

      def translate_class(class_str)
        class_str.split(/\s+/).map { |c| CLASS_MAP[c] || c }.join(" ")
      end

      def block_element?(obj)
        obj.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock) ||
          obj.is_a?(Metanorma::Document::Components::Tables::TableBlock) ||
          obj.is_a?(Metanorma::Document::Components::Lists::UnorderedList) ||
          obj.is_a?(Metanorma::Document::Components::Lists::OrderedList) ||
          obj.is_a?(Metanorma::Document::Components::Lists::DefinitionList) ||
          obj.is_a?(Metanorma::Document::Components::AncillaryBlocks::FigureBlock) ||
          obj.is_a?(Metanorma::Document::Components::Blocks::NoteBlock) ||
          obj.is_a?(Metanorma::Document::Components::AncillaryBlocks::ExampleBlock) ||
          obj.is_a?(Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock) ||
          obj.is_a?(Metanorma::Document::Components::AncillaryBlocks::FormulaBlock) ||
          obj.is_a?(Metanorma::Document::Components::MultiParagraph::QuoteBlock) ||
          obj.is_a?(Metanorma::Document::Components::MultiParagraph::AdmonitionBlock) ||
          obj.is_a?(Metanorma::Document::Components::Sections::HierarchicalSection) ||
          obj.is_a?(Metanorma::Document::Components::Sections::BasicSection) ||
          obj.is_a?(Metanorma::Document::Components::Sections::ContentSection)
      end

      def safe_attr(obj, method_name)
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
          target_text: @current_section_number
        )
      rescue StandardError
        nil
      end

      def extract_block_label(block, default)
        # Presentation XML puts label in <name> child element
        names = safe_attr(block, :name)
        if names && !names.empty?
          name = names.is_a?(Array) ? names.first : names
          text = extract_text_value(name)
          return text unless text.to_s.strip.empty?
        end

        # Fallback: autonum XML attribute
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
        return "" if titles.nil? || titles.empty?

        titles = Array(titles)
        title = titles.first
        extract_text_value(title).to_s
      end

      def escape_html(text)
        return "" if text.nil?

        text
          .to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
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
        return if @footnote_collector.empty?

        drops = @footnote_collector.to_a.map do |entry|
          content_html = ""
          if entry.content && !entry.content.empty?
            content_html = capture_output do
              Array(entry.content).each { |p| render_paragraph(p) }
            end
          end
          Drops::FootnoteDrop.new(entry, content_html)
        end

        @output << render_liquid("_footnotes.html.liquid", { "footnotes" => drops })
      end

      def capture_output
        old_output = @output
        @output = +""
        yield
        result = @output
        @output = old_output
        result
      end
    end
  end
end
