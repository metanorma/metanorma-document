# frozen_string_literal: true

require "stringio"

module Metanorma
  module Html
    # Renders IsoDocument components to HTML.
    # Extends StandardRenderer with ISO-specific cover page, boilerplate,
    # foreword, introduction, annex formatting, and ISO term entries.
    class IsoRenderer < StandardRenderer
      # --- Public hooks for flavor customization ---

      register_render Metanorma::IsoDocument::Root, :render_document
      register_render Metanorma::IsoDocument::Sections::IsoPreface,
                      :render_preface
      register_render Metanorma::IsoDocument::Sections::IsoSections,
                      :render_sections
      register_render Metanorma::IsoDocument::Sections::IsoClauseSection,
                      :render_clause
      register_render Metanorma::IsoDocument::Sections::IsoAnnexSection,
                      :render_annex
      register_render Metanorma::IsoDocument::Sections::IsoTermsSection,
                      :render_terms_section
      register_render Metanorma::IsoDocument::Sections::IsoForewordSection,
                      :render_foreword
      register_render Metanorma::IsoDocument::Sections::IsoAbstractSection,
                      :render_abstract
      register_render Metanorma::IsoDocument::Terms::IsoTerm, :render_term
      register_render Metanorma::IsoDocument::Terms::TermNote, :render_term_note
      register_render Metanorma::IsoDocument::Terms::TermExample,
                      :render_term_example
      register_render Metanorma::IsoDocument::Boilerplate, :render_boilerplate

      register_inline_render Metanorma::IsoDocument::Terms::TermOrigin,
                             :render_term_origin

      def render_term_origin(element)
        text = extract_text_value(element)
        return nil unless text

        render_liquid("_inline_span.html.liquid", {
                        "attrs" => " class=\"term-source\"",
                        "content" => escape_html(text),
                      })
      end

      def extract_display_title(bibdata)
        titles = bibdata.titles
        return nil unless titles

        en_title = bibdata.title_for("en")
        result = en_title&.to_s
        return result if result && !result.empty?

        if titles.is_a?(Metanorma::IsoDocument::Metadata::TitleCollection) && !titles.items.empty?
          raw = titles.items.find do |t|
            t.language == "en"
          end || titles.items.first
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

        raw_id = strip_doc_id_prefix(raw_id)
        pub = flavor_publisher_name
        if pub && !raw_id.start_with?(pub)
          "#{pub} #{raw_id}"
        else
          raw_id
        end
      end

      def strip_doc_id_prefix(raw_id)
        prefix = theme.doc_id_strip_prefix
        return raw_id unless prefix

        raw_id.to_s.gsub(/\A#{Regexp.escape(prefix)}\s+/, "").strip
      end

      def extract_stage(bibdata)
        return nil unless bibdata.status&.stage

        stages = Array(bibdata.status.stage)
        return nil if stages.empty?

        en_stage = stages.find do |s|
          lang = safe_attr(s, :language)
          lang == "en" if lang
        end
        return Array(en_stage.value).join.strip if en_stage&.value

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

      def extract_doctype(bibdata)
        return nil unless bibdata.is_a?(Metanorma::IsoDocument::Metadata::IsoBibliographicItem)

        ext = bibdata.ext
        return nil unless ext

        doctypes = ext.doctype
        return nil unless doctypes && !doctypes.empty?

        en_dt = doctypes.find do |d|
          lang = safe_attr(d, :language)
          lang == "en" if lang
        end
        return en_dt.value.to_s if en_dt&.value

        dt = doctypes.first
        val = dt&.value.to_s
        val.strip.empty? ? nil : val
      end

      # --- Top-level document rendering ---

      def render_document(doc, **_opts)
        parts = []
        parts << (render_coverpage(doc) || "")
        parts << (render_boilerplate_section(doc) || "")

        parts << (render(doc.preface) || "") if doc.preface
        parts << (render_doc_title(doc) || "")

        all_items = collect_document_children(doc)
        all_items.each do |node|
          next if node.is_a?(String)
          next if is_title_element?(node, doc.sections)

          parts << (render(node) || "")
        end

        parts << (render_footnotes_section || "")

        render_liquid("_main_content.html.liquid", {
                        "content" => parts.join,
                      })
      end

      # --- Cover page ---

      def render_coverpage(doc)
        bibdata = doc.bibdata
        return "" unless bibdata

        logos = publisher_logos_html(doc) || []
        doc_id = formatted_doc_id(bibdata)

        pub_date = nil
        bibdata.date&.each do |date|
          date_type = extract_text_value(safe_attr(date,
                                                   :type_attr) || safe_attr(
                                                     date, :type
                                                   ))
          date_val = extract_text_value(date.is_a?(Metanorma::Document::Relaton::BibliographicDate) ? date.on : safe_attr(
            date, :text
          ))
          if date_type == "published" && date_val
            pub_date = date_val
          end
        end

        doctype = extract_doctype(bibdata)

        title_text = nil
        if bibdata.titles
          en_title = bibdata.title_for("en")
          if en_title
            title_text = if en_title.is_a?(Metanorma::IsoDocument::Metadata::AbstractTitle) && en_title.value
                           en_title.value.to_s
                         else
                           en_title.to_s
                         end
          end
        end

        stage_text = extract_stage(bibdata)

        render_liquid("_standard_cover.html.liquid", {
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
        return nil unless bibdata

        titles = bibdata.titles
        return nil unless titles

        en_title = bibdata.title_for("en")
        return nil unless en_title

        render_liquid("_standard_doc_title.html.liquid", {
                        "title" => en_title.to_s,
                      })
      end

      def render_boilerplate_section(doc)
        return nil unless doc.boilerplate

        content = render(doc.boilerplate)
        render_liquid("_prefatory_section.html.liquid", {
                        "content" => content,
                      })
      end

      def render_foreword(fw, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(fw, :id))
        title = safe_attr(fw, :fmt_title) || safe_attr(fw, :title)
        parts = []
        if title
          fw_id = safe_attr(fw, :id)
          title_content = render_mixed_inline(title)
          register_toc_entry(id: fw_id, level: level,
                             text: extract_plain_text(title))
          parts << render_liquid("_heading.html.liquid", {
                                   "tag" => "h1",
                                   "class_attr" => " class=\"foreword-title\"",
                                   "content" => title_content,
                                 })
        end
        parts << (render_ordered_content(fw) || "")
        render_liquid("_element.html.liquid", "tag" => "div",
                                              "extra_attrs" => attrs, "content" => parts.join)
      end

      def render_abstract(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        title = safe_attr(section, :fmt_title) || safe_attr(section, :title)
        parts = []
        if title
          sec_id = safe_attr(section, :id)
          title_content = render_mixed_inline(title)
          register_toc_entry(id: sec_id, level: level,
                             text: extract_plain_text(title))
          parts << render_liquid("_heading.html.liquid", {
                                   "tag" => "h1",
                                   "class_attr" => " class=\"intro-title\"",
                                   "content" => title_content,
                                 })
        end
        parts << (render_ordered_content(section) || "")
        render_liquid("_element.html.liquid", "tag" => "div",
                                              "extra_attrs" => attrs, "content" => parts.join)
      end

      # --- Main sections rendering ---

      def render_sections(sections, **_opts)
        children = collect_ordered_children(sections)
        parts = []
        children.each do |node|
          next if node.is_a?(String)
          next if is_title_element?(node, sections)

          parts << (render(node, level: 1) || "")
        end
        parts.join
      end

      # --- Clause rendering ---

      def render_clause(clause, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(clause, :id))
        title = render_title(clause, level)
        content = render_ordered_content(clause, level)
        render_liquid("_element.html.liquid", "tag" => "div",
                                              "extra_attrs" => attrs, "content" => "#{title}#{content}")
      end

      # --- Annex rendering ---

      def render_annex(annex, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(annex, :id), class: "section-sub")
        title = render_annex_title(annex, level)
        content = render_ordered_content(annex, level)
        render_liquid("_element.html.liquid", "tag" => "div",
                                              "extra_attrs" => attrs, "content" => "#{title}#{content}")
      end

      def render_annex_title(annex, level)
        title_element = safe_attr(annex, :fmt_title) || safe_attr(annex, :title)
        return nil unless title_element

        annex_id = safe_attr(annex, :id)
        title_content = render_mixed_inline(title_element)
        register_toc_entry(id: annex_id, level: level,
                           text: extract_plain_text(title_element))

        h = "h#{[[level, 6].min, 1].max}"
        render_liquid("_heading.html.liquid", {
                        "tag" => h,
                        "class_attr" => " class=\"annex-title\"",
                        "content" => title_content,
                      })
      end

      # --- Terms section rendering ---

      def render_terms_section(terms, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(terms, :id))
        title = render_title(terms, level)
        content = render_ordered_content(terms, level)
        render_liquid("_element.html.liquid", "tag" => "div",
                                              "extra_attrs" => attrs, "content" => "#{title}#{content}")
      end

      # --- ISO Term rendering ---

      def render_term(term, **_opts)
        term_name = extract_term_name(term)
        term_def = extract_term_definition(term)
        data_attrs = {}
        if term_name && !term_name.empty?
          data_attrs["data-term-name"] = term_name
        end
        if term_def && !term_def.empty?
          data_attrs["data-term-definition"] = term_def
        end
        attrs = element_attrs(id: safe_attr(term, :id), **data_attrs)
        fmt_name = safe_attr(term, :fmt_name)
        fmt_preferred = safe_attr(term, :fmt_preferred)
        fmt_admitted = safe_attr(term, :fmt_admitted)
        fmt_deprecates = safe_attr(term, :fmt_deprecates)
        fmt_definition = safe_attr(term, :fmt_definition)
        fmt_termsource = safe_attr(term, :fmt_termsource)
        term_number = safe_attr(term, :term_number)
        term_p = safe_attr(term, :p)
        term_note = safe_attr(term, :termnote) || Array(safe_attr(term, :note))
        term_example = safe_attr(term,
                                 :termexample) || Array(safe_attr(term,
                                                                  :example))
        term_termsource = safe_attr(term, :termsource)
        term_admonition = safe_attr(term, :admonition)
        term_nested = safe_attr(term, :term)

        parts = []
        if fmt_name
          tn_content = render_inline_element(fmt_name)
          parts << render_liquid("_term_number.html.liquid",
                                 { "content" => tn_content })
        elsif term_number
          tn_text = if term_number.is_a?(String)
                      term_number
                    else
                      extract_text_value(term_number)
                    end
          parts << render_liquid("_term_number.html.liquid",
                                 { "content" => escape_html(tn_text) })
        end

        if fmt_preferred && !fmt_preferred.empty?
          fmt_preferred.each do |fp|
            fp.p&.each { |para| parts << (render_paragraph(para) || "") }
          end
        elsif term.preferred && !term.preferred.empty?
          term.preferred&.each do |designation|
            parts << (render_term_designation(designation, "preferred") || "")
          end
        end

        if fmt_admitted && !fmt_admitted.empty?
          fmt_admitted.each do |fa|
            fa.p&.each { |para| parts << (render_paragraph(para) || "") }
          end
        elsif term.admitted && !term.admitted.empty?
          term.admitted&.each do |designation|
            parts << (render_term_designation(designation, "admitted") || "")
          end
        end

        if fmt_deprecates
          fmt_deprecates.p&.each do |para|
            parts << (render_paragraph(para) || "")
          end
        elsif term.deprecates && !term.deprecates.empty?
          term.deprecates&.each do |designation|
            parts << (render_term_designation(designation, "deprecated") || "")
          end
        end

        if term.domain && !fmt_definition
          domain_text = safe_attr(term.domain, :text)
          if domain_text
            parts << render_liquid("_term_domain.html.liquid", {
                                     "text" => escape_html(domain_text),
                                   })
          end
        end

        if fmt_definition
          parts << (render_ordered_content(fmt_definition) || "")
        else
          term_p&.each { |para| parts << (render_paragraph(para) || "") }
          term.definition&.each do |defn|
            parts << (render_term_definition(defn) || "")
          end
        end

        term_note&.each { |note| parts << (render_term_note(note) || "") }
        term_example&.each { |ex| parts << (render_term_example(ex) || "") }

        if fmt_termsource && !fmt_termsource.empty?
          fmt_termsource.each do |fts|
            src_content = render_mixed_inline(fts)
            parts << render_liquid("_paragraph.html.liquid", {
                                     "attrs" => " class=\"term-source\"",
                                     "content" => src_content,
                                   })
          end
        else
          term.source&.each { |src| parts << (render_term_source(src) || "") }
          term_termsource&.each do |src|
            parts << (render_term_source_element(src) || "")
          end
        end

        term_admonition&.each { |adm| parts << (render_admonition(adm) || "") }
        term_nested&.each { |sub| parts << (render_term(sub) || "") }

        render_liquid("_element.html.liquid", "tag" => "div",
                                              "extra_attrs" => attrs, "content" => parts.join)
      end

      def extract_term_name(term)
        fmt_pref = safe_attr(term, :fmt_preferred)
        if fmt_pref && !fmt_pref.empty?
          fp = fmt_pref.first
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
        fmt_def = safe_attr(term, :fmt_definition)
        return extract_plain_text(fmt_def) if fmt_def

        term_p = safe_attr(term, :p)
        if term_p && !term_p.empty?
          text = term_p.map { |para| extract_plain_text(para) }.join(" ")
          return text.strip unless text.strip.empty?
        end
        nil
      end

      def render_term_designation(designation, type)
        css_class = type == "deprecated" ? "term-deprecated" : "term-name"
        name = extract_designation_name(designation)
        inner = if name
                  escape_html(name)
                else
                  render_mixed_inline(designation) || ""
                end

        dfn_content = render_liquid("_element.html.liquid",
                                    { "tag" => "dfn", "extra_attrs" => "",
                                      "content" => inner })
        b_content = render_liquid("_element.html.liquid",
                                  { "tag" => "b", "extra_attrs" => "",
                                    "content" => dfn_content })

        if type == "deprecated"
          b_content = render_liquid("_element.html.liquid",
                                    { "tag" => "del", "extra_attrs" => "",
                                      "content" => b_content })
        end

        render_liquid("_element.html.liquid", {
                        "tag" => "p",
                        "extra_attrs" => " class=\"#{css_class}\" style=\"text-align:left;\"",
                        "content" => b_content,
                      })
      end

      def extract_designation_name(designation)
        expr = designation.expression
        if expr.is_a?(Metanorma::IsoDocument::Terms::TermExpression) && expr.name
          names = Array(expr.name)
          text = names.map { |n| extract_name_text(n) }.join
          return text unless text.strip.empty?
        end

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
        return nil unless definition

        parts = []
        rendered = false

        vd = safe_attr(definition,
                       :verbal_definition) || safe_attr(definition,
                                                        :verbalexpression)
        if vd
          vd_p = safe_attr(vd, :p) || safe_attr(vd, :paragraph)
          vd_p&.each { |para| parts << (render_paragraph(para) || "") }
          vd.ul&.each { |ul| parts << (render_unordered_list(ul) || "") }
          vd.ol&.each { |ol| parts << (render_ordered_list(ol) || "") }
          rendered = true
        end

        p_children = safe_attr(definition, :p)
        if !rendered && p_children && !p_children.empty?
          p_children.each { |para| parts << (render_paragraph(para) || "") }
          rendered = true
        end

        unless rendered
          parts << (render_ordered_content(definition) || "")
        end
        parts.join
      end

      # --- Boilerplate rendering ---

      def render_boilerplate(boilerplate, **_opts)
        return nil unless boilerplate

        parts = []
        parts << (render_boilerplate_items(boilerplate.copyright_statement) || "")
        parts << (render_boilerplate_items(boilerplate.license_statement) || "")
        parts << (render_boilerplate_items(boilerplate.legal_statement) || "")
        parts << (render_boilerplate_items(boilerplate.feedback_statement) || "")
        parts << (render_boilerplate_items(boilerplate.clause) || "")

        render_liquid("_boilerplate.html.liquid", content: parts.join)
      end

      def render_boilerplate_items(items)
        return nil unless items

        Array(items).filter_map { |item| render_boilerplate_clause(item) }.join
      end

      def render_boilerplate_clause(item)
        return nil unless item
        return nil unless item.is_a?(Lutaml::Model::Serializable)

        inner = safe_attr(item, :subsection)
        targets = if inner && !Array(inner).empty?
                    Array(inner)
                  else
                    [item]
                  end

        targets.filter_map do |section|
          render_boilerplate_clause_content(section)
        end.join
      end

      def render_boilerplate_clause_content(section)
        fmt_title = safe_attr(section, :fmt_title)
        parts = []
        section.each_mixed_content do |child|
          next if child.is_a?(String)
          next if is_title_element?(child, section)
          next if child.equal?(fmt_title)

          parts << (render(child) || "")
        end
        parts.join
      end

      # --- Helpers ---

      def render_title(section, level)
        title_element = safe_attr(section,
                                  :fmt_title) || safe_attr(section, :title)
        return nil unless title_element

        section_id = safe_attr(section, :id)
        title_content = render_mixed_inline(title_element)
        register_toc_entry(id: section_id, level: level,
                           text: extract_plain_text(title_element))

        h = "h#{[[level, 6].min, 1].max}"
        render_liquid("_heading.html.liquid", tag: h, class_attr: "",
                                              content: title_content)
      end

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

        dark_logo_map = theme.logos_dark
        display_pubs = publishers.empty? ? logo_map.keys : publishers
        display_pubs.filter_map do |pub|
          filename = logo_map[pub]
          next unless filename

          svg = load_logo_svg(filename, height: 48)
          next unless svg

          light_span = "<span class=\"cover-logo cover-logo-light\">#{svg}</span>"

          dark_span = ""
          dark_filename = dark_logo_map[pub]
          if dark_filename
            dark_svg = load_logo_svg(dark_filename, height: 48)
            if dark_svg
              dark_span = "<span class=\"cover-logo cover-logo-dark\">#{dark_svg}</span>"
            end
          end

          dark_span.empty? ? light_span : "#{light_span}\n#{dark_span}"
        end
      end
    end
  end
end
