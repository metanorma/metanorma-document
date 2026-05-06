# frozen_string_literal: true

require "stringio"

module Metanorma
  module Html
    # Renders IsoDocument components to HTML.
    # Extends StandardRenderer with ISO-specific cover page, boilerplate,
    # foreword, introduction, annex formatting, and ISO term entries.
    class IsoRenderer < StandardRenderer
      # --- Public hooks for flavor customization ---

      def flavor_publishers(_doc_id)
        ["ISO"]
      end

      def flavor_publisher_name
        "ISO"
      end

      def publisher_logo_map
        { "ISO" => "iso-logo.svg" }
      end

      # ISO brand: #e3000f red from logo
      def theme
        @theme ||= Theme.new.tap do |t|
          t.primary        = "#b3000c"
          t.accent         = "#e3000f"
          t.accent_deep    = "#b3000c"
          t.gradient       = "linear-gradient(135deg, #8a0009 0%, #b3000c 50%, #e3000f 100%)"
          t.primary_light  = "#fef0f1"
          t.accent_light   = "#fde8ea"
          t.warm           = "#1a1a1a"
          t.warm_light     = "#f5f5f5"
          t.header_background = "linear-gradient(135deg, #8a0009 0%, #b3000c 40%, #e3000f 100%)"
          t.cover_background  = "linear-gradient(175deg, #5a0006 0%, #8a0009 25%, #b3000c 50%, #e3000f 80%, #ff4d4d 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 25% 20%, rgba(255,77,77,0.15) 0%, transparent 50%), radial-gradient(ellipse at 75% 80%, rgba(26,26,26,0.1) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #e3000f, #1a1a1a, transparent)"
          t.progress_bar_color = "#e3000f"
          t.note_border     = "#e3000f"
          t.note_bg         = "#fde8ea"
          t.note_color      = "#e3000f"
          t.example_border  = "#b3000c"
          t.example_bg      = "#fef0f1"
          t.example_color   = "#b3000c"
          t.admonition_border = "#1a1a1a"
          t.admonition_color  = "#1a1a1a"
          t.footer_border_color = "#e3000f"
          t.cover_separator_color = "rgba(227,0,15,0.25)"
        end
      end

      register_render Metanorma::IsoDocument::Root, :render_document
      register_render Metanorma::IsoDocument::Sections::IsoPreface, :render_preface
      register_render Metanorma::IsoDocument::Sections::IsoSections, :render_sections
      register_render Metanorma::IsoDocument::Sections::IsoClauseSection, :render_clause
      register_render Metanorma::IsoDocument::Sections::IsoAnnexSection, :render_annex
      register_render Metanorma::IsoDocument::Sections::IsoTermsSection, :render_terms_section
      register_render Metanorma::IsoDocument::Sections::IsoForewordSection, :render_foreword
      register_render Metanorma::IsoDocument::Sections::IsoAbstractSection, :render_abstract
      register_render Metanorma::IsoDocument::Terms::IsoTerm, :render_term
      register_render Metanorma::IsoDocument::Terms::TermNote, :render_term_note
      register_render Metanorma::IsoDocument::Terms::TermExample, :render_term_example
      register_render Metanorma::IsoDocument::Boilerplate, :render_boilerplate

      register_inline_render Metanorma::IsoDocument::Terms::TermOrigin, :render_term_origin

      def render_term_origin(element)
        text = extract_text_value(element)
        return unless text

        @output << "<span class=\"term-source\">#{escape_html(text)}</span>"
      end

      def extract_display_title(bibdata)
        titles = bibdata.titles
        return nil unless titles

        en_title = bibdata.title_for("en")
        result = en_title&.to_s
        return result if result && !result.empty?

        if titles.is_a?(Metanorma::IsoDocument::Metadata::TitleCollection) && !titles.items.empty?
          raw = titles.items.find { |t| t.language == "en" } || titles.items.first
          return raw.value.to_s if raw&.value
        end
        nil
      end

      # Format doc identifier with publisher prefix (e.g. "OGC 00-027").
      def formatted_doc_id(bibdata)
        identifiers = bibdata.doc_identifier
        return nil unless identifiers && !identifiers.empty?

        raw_id = extract_text_value(identifiers.first).to_s.strip
        return nil if raw_id.empty?

        pub = flavor_publisher_name
        if pub && !raw_id.start_with?(pub)
          "#{pub} #{raw_id}"
        else
          raw_id
        end
      end

      # Extract English stage text, deduplicating duplicate language variants.
      def extract_stage(bibdata)
        return nil unless bibdata.status&.stage

        stages = Array(bibdata.status.stage)
        return nil if stages.empty?

        # Prefer English-language stage
        en_stage = stages.find do |s|
          lang = safe_attr(s, :language)
          lang == "en" if lang
        end
        return Array(en_stage.value).join.strip if en_stage&.value

        # Fallback: first non-empty, deduplicated
        seen = Set.new
        stage_text = stages.filter_map do |s|
          val = Array(s.value).join.strip
          down = val.downcase
          next if seen.include?(down)

          seen << down
          val.empty? ? nil : val
        end.compact.join(" ")
        stage_text.empty? ? nil : stage_text
      end

      # Extract document type from ext.doctype.
      def extract_doctype(bibdata)
        return nil unless bibdata.is_a?(Metanorma::IsoDocument::Metadata::IsoBibliographicItem)

        ext = bibdata.ext
        return nil unless ext

        doctypes = ext.doctype
        return nil unless doctypes && !doctypes.empty?

        # Prefer English-language doctype
        en_dt = doctypes.find do |d|
          lang = safe_attr(d, :language)
          lang == "en" if lang
        end
        return en_dt.value.to_s if en_dt&.value

        # Fallback: first doctype
        dt = doctypes.first
        val = dt&.value.to_s
        val.strip.empty? ? nil : val
      end

      private

      # --- Top-level document rendering ---

      def render_document(doc, **_opts)
        render_coverpage(doc)
        render_boilerplate_section(doc)

        @output << "<main class=\"main-section\">"

        # Preface sections
        render(doc.preface) if doc.preface

        # Document title line
        render_doc_title(doc)

        # Collect ALL top-level content (sections + normative refs + annexes + bibliography)
        # and render in displayorder for correct document order.
        all_items = collect_document_children(doc)

        all_items.each do |node|
          next if node.is_a?(String)
          next if is_title_element?(node, doc.sections)

          render(node)
        end

        render_footnotes_section

        @output << "</main>"
      end

      # --- Cover page ---

      def render_coverpage(doc)
        bibdata = doc.bibdata
        return unless bibdata

        logos = publisher_logos_html(doc) || []
        doc_id = formatted_doc_id(bibdata)

        pub_date = nil
        bibdata.date&.each do |date|
          date_type = extract_text_value(safe_attr(date, :type_attr) || safe_attr(date, :type))
          date_val = extract_text_value(date.is_a?(Metanorma::Document::Relaton::BibliographicDate) ? date.on : safe_attr(date, :text))
          if date_type == "published" && date_val
            pub_date = date_val
          end
        end

        doctype = extract_doctype(bibdata)

        title_text = nil
        if bibdata.titles
          en_title = bibdata.title_for("en")
          title_text = en_title.to_s if en_title
        end

        stage_text = extract_stage(bibdata)

        @output << render_liquid("_iso_cover.html.liquid", {
                                   "publisher_logos" => logos,
                                   "doc_id" => doc_id,
                                   "pub_date" => pub_date,
                                   "doctype" => doctype,
                                   "title" => title_text,
                                   "stage" => stage_text,
                                 })
      end

      def render_doc_title(doc)
        bibdata = doc.bibdata
        return unless bibdata

        titles = bibdata.titles
        return unless titles

        en_title = bibdata.title_for("en")
        return unless en_title

        @output << render_liquid("_iso_doc_title.html.liquid", {
                                   "title" => en_title.to_s,
                                 })
      end

      def render_boilerplate_section(doc)
        return unless doc.boilerplate

        @output << "<div class=\"prefatory-section\">"
        render(doc.boilerplate)
        @output << "</div><hr class=\"cover-separator\" />"
      end

      def render_preface(preface, **_opts)
        render(preface.foreword) if preface.foreword
        render(preface.introduction) if preface.introduction
        render(preface.abstract) if preface.abstract
        preface.clause&.each { |cl| render(cl, level: 1) }
        render(preface.acknowledgements) if preface.acknowledgements
        render(preface.executivesummary) if preface.executivesummary
      end

      def render_foreword(fw, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(fw, :id))
        tag("div", attrs) do
          title = safe_attr(fw, :fmt_title) || safe_attr(fw, :title)
          if title
            fw_id = safe_attr(fw, :id)
            title_text = extract_plain_text(title)
            register_toc_entry(id: fw_id, level: level, text: title_text)
            @output << "<h1 class=\"foreword-title\">"
            render_mixed_inline(title)
            @output << "</h1>"
          end
          render_ordered_content(fw)
        end
      end

      def render_abstract(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          title = safe_attr(section, :fmt_title) || safe_attr(section, :title)
          if title
            sec_id = safe_attr(section, :id)
            title_text = extract_plain_text(title)
            register_toc_entry(id: sec_id, level: level, text: title_text)
            @output << "<h1 class=\"intro-title\">"
            render_mixed_inline(title)
            @output << "</h1>"
          end
          render_ordered_content(section)
        end
      end

      # --- Main sections rendering ---

      def render_sections(sections, **_opts)
        # Collect ALL section-level children (from mixed content AND typed attributes)
        # then sort by displayorder for correct document order.
        children = collect_ordered_children(sections)
        children.each do |node|
          next if node.is_a?(String)
          next if is_title_element?(node, sections)

          render(node, level: 1)
        end
      end

      # --- Clause rendering ---

      def render_clause(clause, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(clause, :id))
        tag("div", attrs) do
          render_title(clause, level)
          render_ordered_content(clause, level)
        end
      end

      # --- Annex rendering ---

      def render_annex(annex, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(annex, :id), class: "section-sub")
        tag("div", attrs) do
          render_annex_title(annex, level)
          render_ordered_content(annex, level)
        end
      end

      def render_annex_title(annex, level)
        title_element = safe_attr(annex, :fmt_title) || safe_attr(annex, :title)
        return unless title_element

        annex_id = safe_attr(annex, :id)
        title_text = extract_plain_text(title_element)
        register_toc_entry(id: annex_id, level: level, text: title_text)

        h = "h#{[[level, 6].min, 1].max}"
        @output << "<#{h} class=\"annex-title\">"
        render_mixed_inline(title_element)
        @output << "</#{h}>"
      end

      # --- Terms section rendering ---

      def render_terms_section(terms, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(terms, :id))
        tag("div", attrs) do
          render_title(terms, level)
          render_ordered_content(terms, level)
        end
      end

      # --- ISO Term rendering ---

      def render_term(term, **_opts)
        term_name = extract_term_name(term)
        term_def = extract_term_definition(term)
        data_attrs = {}
        data_attrs["data-term-name"] = term_name if term_name && !term_name.empty?
        data_attrs["data-term-definition"] = term_def if term_def && !term_def.empty?
        attrs = element_attrs(id: safe_attr(term, :id), **data_attrs)
        tag("div", attrs) do
          # In presentation mode, use fmt_* elements
          if term.fmt_name
            # Render term number (e.g. "3.1")
            @output << "<p class=\"term-number\">"
            render_inline_element(term.fmt_name)
            @output << "</p>"
          elsif term.term_number
            tn = term.term_number
            tn_text = if tn.is_a?(String)
                        tn
                      else
                        extract_text_value(tn)
                      end
            @output << "<p class=\"term-number\">#{escape_html(tn_text)}</p>"
          end

          # Preferred designations — use fmt-preferred if available
          if term.fmt_preferred && !term.fmt_preferred.empty?
            term.fmt_preferred.each { |fp| fp.p&.each { |para| render_paragraph(para) } }
          elsif term.preferred && !term.preferred.empty?
            term.preferred&.each { |designation| render_term_designation(designation, "preferred") }
          end

          # Admitted designations — use fmt-admitted if available
          if term.fmt_admitted && !term.fmt_admitted.empty?
            term.fmt_admitted.each { |fa| fa.p&.each { |para| render_paragraph(para) } }
          elsif term.admitted && !term.admitted.empty?
            term.admitted&.each { |designation| render_term_designation(designation, "admitted") }
          end

          # Deprecated designations — use fmt-deprecates if available
          if term.fmt_deprecates
            term.fmt_deprecates.p&.each { |para| render_paragraph(para) }
          elsif term.deprecates && !term.deprecates.empty?
            term.deprecates&.each { |designation| render_term_designation(designation, "deprecated") }
          end

          # Domain — only render separately when fmt-definition is absent
          # (fmt-definition already includes domain text in its content)
          if term.domain && !term.fmt_definition
            domain_text = safe_attr(term.domain, :text)
            @output << "<p class=\"term-domain\">&lt;#{escape_html(domain_text)}&gt;</p>" if domain_text
          end

          # Definition — use fmt-definition if available
          if term.fmt_definition
            render_ordered_content(term.fmt_definition)
          else
            # Definition paragraphs
            term.p&.each { |para| render_paragraph(para) }
            # Structured definitions
            term.definition&.each { |defn| render_term_definition(defn) }
          end

          # Term notes
          term.termnote&.each { |note| render_term_note(note) }

          # Term examples
          term.termexample&.each { |ex| render_term_example(ex) }

          # Source references — use fmt-termsource if available
          if term.fmt_termsource && !term.fmt_termsource.empty?
            term.fmt_termsource.each do |fts|
              @output << "<p class=\"term-source\">"
              render_mixed_inline(fts)
              @output << "</p>"
            end
          else
            term.source&.each { |src| render_term_source(src) }
            term.termsource&.each { |src| render_term_source_element(src) }
          end

          # Admonitions
          term.admonition&.each { |adm| render_admonition(adm) }

          # Nested terms
          term.term&.each { |sub| render_term(sub) }
        end
      end

      def extract_term_name(term)
        if term.fmt_preferred && !term.fmt_preferred.empty?
          fp = term.fmt_preferred.first
          if fp.p && !fp.p.empty?
            return extract_plain_text(fp.p.first)
          end
        end
        if term.preferred && !term.preferred.empty?
          return extract_designation_name(term.preferred.first).to_s
        end

        safe_attr(term, :id).to_s.delete_prefix("term-")
      end

      def extract_term_definition(term)
        if term.fmt_definition
          rendered = capture_output { render_ordered_content(term.fmt_definition) }
          return strip_html(rendered).gsub(/\s+/, " ").strip
        end
        if term.p && !term.p.empty?
          rendered = capture_output { term.p.each { |para| render_paragraph(para) } }
          return strip_html(rendered).gsub(/\s+/, " ").strip
        end
        nil
      end

      def strip_html(html)
        html.gsub(/<[^>]+>/, "").gsub("&lt;", "<").gsub("&gt;", ">")
          .gsub("&amp;", "&").gsub("&nbsp;", " ")
      end

      def render_term_designation(designation, type)
        css_class = type == "deprecated" ? "term-deprecated" : "term-name"
        @output << "<p class=\"#{css_class}\" style=\"text-align:left;\">"
        @output << "<del>" if type == "deprecated"
        @output << "<b><dfn>"

        name = extract_designation_name(designation)
        if name
          @output << escape_html(name)
        else
          # Fallback: render mixed content (e.g. <strong> element)
          render_mixed_inline(designation)
        end

        @output << "</dfn></b>"
        @output << "</del>" if type == "deprecated"
        @output << "</p>"
      end

      def extract_designation_name(designation)
        # Try expression.name first (TermNameElement objects with text)
        expr = designation.expression
        if expr.is_a?(Metanorma::IsoDocument::Terms::TermExpression) && expr.name
          names = Array(expr.name)
          text = names.map { |n| extract_name_text(n) }.join
          return text unless text.strip.empty?
        end

        # Try text attribute from mixed content
        texts = safe_attr(designation, :text)
        if texts
          joined = texts.is_a?(Array) ? texts.join : texts.to_s
          return joined unless joined.strip.empty?
        end

        nil
      end

      def extract_name_text(name_el)
        return name_el.to_s unless name_el.is_a?(Lutaml::Model::Serializable)

        texts = safe_attr(name_el, :text)
        if texts
          joined = texts.is_a?(Array) ? texts.join : texts.to_s
          return joined unless joined.strip.empty?
        end

        ""
      end

      def render_term_definition(definition)
        return unless definition

        rendered = false

        # Try verbal_definition first (ISO semantic format)
        vd = definition.verbal_definition
        if vd
          vd.p&.each { |para| render_paragraph(para) }
          vd.ul&.each { |ul| render_unordered_list(ul) }
          vd.ol&.each { |ol| render_ordered_list(ol) }
          rendered = true
        end

        # Try direct p (presentation XML format where <p> is inside <definition>)
        p_children = safe_attr(definition, :p)
        if !rendered && p_children && !p_children.empty?
          p_children.each { |para| render_paragraph(para) }
          rendered = true
        end

        # Fallback: render via element_order
        unless rendered
          render_ordered_content(definition)
        end
      end

      # --- Boilerplate rendering ---

      def render_boilerplate(boilerplate, **_opts)
        return unless boilerplate

        content = boilerplate.content
        return unless content

        @output << "<div class=\"boilerplate-copyright\">"

        raw = content.to_s
        clean = convert_boilerplate_links(raw)
          .gsub(/<fmt-title[^>]*>.*?<\/fmt-title>/m, "")
          .gsub(/<semx[^>]*>.*?<\/semx>/m, "")
          .gsub(/<title[^>]*>.*?<\/title>/m, "")
          .gsub(/<fmt-xref-label[^>]*>.*?<\/fmt-xref-label>/m, "")
          .gsub(/<variant-title[^>]*>.*?<\/variant-title>/m, "")
          .gsub(/<\/?(?:copyright-statement|clause)[^>]*>/, "")

        # Remap XML class names to HTML-specific class names
        boilerplate_doc = Nokogiri::HTML::DocumentFragment.parse(clean)
        boilerplate_doc.css("[class]").each do |el|
          el["class"] = el["class"].split(/\s+/).map { |c| html_class_for_span(c) }.join(" ")
        end

        @output << boilerplate_doc.inner_html.strip

        @output << "</div>"
      end

      def convert_boilerplate_links(raw)
        doc = Nokogiri::XML.fragment(raw)
        doc.css("link").each do |link|
          target = link["target"] || link["href"]
          next_sib = link.next_sibling
          while next_sib.is_a?(Nokogiri::XML::Text) && next_sib.text.strip.empty?
            next_sib = next_sib.next_sibling
          end

          display_text = if next_sib&.element? && next_sib.name == "semx"
                           fmt_link = next_sib.at_css("fmt-link")
                           if fmt_link
                             fmt_target = fmt_link["target"] || fmt_link["href"] || target
                             display_text = fmt_target.to_s.delete_prefix("mailto:")
                             next_sib.remove
                             display_text
                           end
                         end

          display_text ||= target.to_s.delete_prefix("mailto:")
          a_tag = Nokogiri::HTML::DocumentFragment.parse(
            "<a href=\"#{CGI.escapeHTML(target.to_s)}\">#{CGI.escapeHTML(display_text)}</a>",
          )
          link.replace(a_tag)
        end
        doc.inner_html
      end

      # --- Helpers ---

      def render_title(section, level)
        title_element = safe_attr(section, :fmt_title) || safe_attr(section, :title)
        return unless title_element

        section_id = safe_attr(section, :id)
        title_text = extract_plain_text(title_element)
        register_toc_entry(id: section_id, level: level, text: title_text)

        h = "h#{[[level, 6].min, 1].max}"
        @output << "<#{h}>"
        render_mixed_inline(title_element)
        @output << "</#{h}>"
      end

      # Collect all document-level children (sections, normative refs, annexes,
      # bibliography) sorted by displayorder for correct document order.
      # Top-level paragraphs in sections (title paragraphs) are excluded —
      # they are rendered separately by render_doc_title.
      def collect_document_children(doc)
        items = []

        if doc.sections
          section_children = collect_ordered_children(doc.sections)
          section_children.reject! do |node|
            node.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
          end
          items.concat(section_children)
        end

        doc.bibliography&.references&.each { |r| items << r }
        doc.annex&.each { |a| items << a }

        items.compact!
        sort_by_displayorder(items)
      end

      def publisher_logos_html(_doc)
        publishers = flavor_publishers(extract_primary_doc_id)
        logo_map = publisher_logo_map
        return [] if publishers.empty? && logo_map.empty?

        display_pubs = publishers.empty? ? logo_map.keys : publishers
        display_pubs.filter_map do |pub|
          filename = logo_map[pub]
          next unless filename

          svg = load_logo_svg(filename, height: 48)
          next unless svg

          # White fill for dark cover background
          svg = svg.gsub("fill:#00b1ff", "fill:white") if pub == "OGC"
          svg = svg.gsub("fill:#e3000f", "fill:white") if pub == "ISO"
          svg
        end
      end
    end
  end
end
