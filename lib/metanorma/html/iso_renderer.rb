# frozen_string_literal: true

module Metanorma
  module Html
    # Renders IsoDocument components to HTML.
    # Extends StandardRenderer with ISO-specific cover page, boilerplate,
    # foreword, introduction, annex formatting, and ISO term entries.
    class IsoRenderer < StandardRenderer
      def render(node, **opts)
        case node
        when Metanorma::IsoDocument::Root
          render_iso_document(node, **opts)
        when Metanorma::IsoDocument::Sections::IsoPreface
          render_iso_preface(node, **opts)
        when Metanorma::IsoDocument::Sections::IsoSections
          render_iso_sections(node, **opts)
        when Metanorma::IsoDocument::Sections::IsoClauseSection
          render_iso_clause(node, **opts)
        when Metanorma::IsoDocument::Sections::IsoAnnexSection
          render_iso_annex(node, **opts)
        when Metanorma::IsoDocument::Sections::IsoTermsSection
          render_iso_terms_section(node, **opts)
        when Metanorma::IsoDocument::Sections::IsoForewordSection
          render_iso_foreword(node, **opts)
        when Metanorma::IsoDocument::Sections::IsoAbstractSection
          render_iso_abstract(node, **opts)
        when Metanorma::IsoDocument::Terms::IsoTerm
          render_iso_term(node, **opts)
        when Metanorma::IsoDocument::Terms::TermNote
          render_iso_term_note(node, **opts)
        when Metanorma::IsoDocument::Terms::TermExample
          render_iso_term_example(node, **opts)
        when Metanorma::IsoDocument::Boilerplate
          render_iso_boilerplate(node, **opts)
        else
          super
        end
      end

      private

      # --- Top-level document rendering ---

      def render_iso_document(doc, **_opts)
        render_iso_coverpage(doc)
        render_iso_boilerplate_section(doc)

        @output << "<main class=\"main-section\">"

        # Preface sections
        render(doc.preface) if doc.preface

        # Document title line
        render_iso_doc_title(doc)

        # Collect ALL top-level content (sections + normative refs + annexes + bibliography)
        # and render in displayorder for correct document order.
        all_items = collect_document_children(doc)

        all_items.each do |node|
          next if node.is_a?(String)
          render(node)
        end

        @output << "</main>"
      end

      # --- Cover page ---

      def render_iso_coverpage(doc)
        bibdata = doc.bibdata
        return unless bibdata

        @output << "<div class=\"title-section\">"

        # Document identifiers
        bibdata.doc_identifier&.each do |di|
          id = extract_text_value(di)
          next if id.to_s.empty?

          @output << "<p class=\"coverpage_docnumber\">#{escape_html(id)}</p>"
        end

        # Document dates
        bibdata.date&.each do |date|
          date_type = extract_text_value(safe_attr(date, :type_attr) || safe_attr(date, :type))
          date_val = extract_text_value(date.respond_to?(:on) ? date.on : safe_attr(date, :text))
          if date_type == "published" && date_val
            @output << "<p class=\"coverpage_docnumber\">#{escape_html(date_val)}</p>"
          end
        end

        # Title
        if bibdata.titles
          en_title = bibdata.title_for("en")
          if en_title
            @output << "<div class=\"doctitle-en\"><div>"
            @output << "<span class=\"subtitle\">#{escape_html(en_title)}</span>"
            @output << "</div></div>"
          end
        end

        # Status/stage
        if bibdata.status && bibdata.status.stage
          stages = Array(bibdata.status.stage)
          stage_text = stages.map { |s| Array(s.value).join }.join(" ")
          unless stage_text.empty?
            @output << "<div class=\"coverpage_docstage\"><p>#{escape_html(stage_text)}</p></div>"
          end
        end

        @output << "</div><hr class=\"cover-separator\" />"
      end

      def render_iso_doc_title(doc)
        bibdata = doc.bibdata
        return unless bibdata

        titles = bibdata.titles
        return unless titles

        en_title = bibdata.title_for("en")
        return unless en_title

        @output << "<p class=\"zzSTDTitle1\">"
        @output << "<span class=\"boldtitle\">#{escape_html(en_title)}</span>"
        @output << "</p>"
      end

      def render_iso_boilerplate_section(doc)
        return unless doc.boilerplate

        @output << "<div class=\"prefatory-section\">"
        render(doc.boilerplate)
        @output << "</div><hr class=\"cover-separator\" />"
      end

      def render_iso_preface(preface, **_opts)
        render(preface.foreword) if preface.foreword
        render(preface.introduction) if preface.introduction
        render(preface.abstract) if preface.abstract
        preface.clause&.each { |cl| render(cl, level: 1) }
        render(preface.acknowledgements) if preface.acknowledgements
        render(preface.executivesummary) if preface.executivesummary
      end

      def render_iso_foreword(fw, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(fw, :id))
        tag("div", attrs) do
          title = safe_attr(fw, :fmt_title) || safe_attr(fw, :title)
          if title
            fw_id = safe_attr(fw, :id)
            title_text = extract_plain_text(title)
            register_toc_entry(id: fw_id, level: level, text: title_text)
            @output << "<h1 class=\"ForewordTitle\">"
            render_mixed_inline(title)
            @output << "</h1>"
          end
          render_ordered_content(fw)
        end
      end

      def render_iso_abstract(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          title = safe_attr(section, :fmt_title) || safe_attr(section, :title)
          if title
            sec_id = safe_attr(section, :id)
            title_text = extract_plain_text(title)
            register_toc_entry(id: sec_id, level: level, text: title_text)
            @output << "<h1 class=\"IntroTitle\">"
            render_mixed_inline(title)
            @output << "</h1>"
          end
          render_ordered_content(section)
        end
      end

      # --- Main sections rendering ---

      def render_iso_sections(sections, **_opts)
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

      def render_iso_clause(clause, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(clause, :id), class: safe_attr(clause, :class_attr))
        tag("div", attrs) do
          render_iso_title(clause, level)
          render_ordered_content(clause, level)
        end
      end

      # --- Annex rendering ---

      def render_iso_annex(annex, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(annex, :id), class: "Section3")
        tag("div", attrs) do
          render_iso_annex_title(annex, level)
          render_ordered_content(annex, level)
        end
      end

      def render_iso_annex_title(annex, level)
        title_element = safe_attr(annex, :fmt_title) || safe_attr(annex, :title)
        return unless title_element

        annex_id = safe_attr(annex, :id)
        title_text = extract_plain_text(title_element)
        register_toc_entry(id: annex_id, level: level, text: title_text)

        h = "h#{[[level, 6].min, 1].max}"
        @output << "<#{h} class=\"Annex\">"
        render_mixed_inline(title_element)
        @output << "</#{h}>"
      end

      # --- Terms section rendering ---

      def render_iso_terms_section(terms, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(terms, :id))
        tag("div", attrs) do
          render_iso_title(terms, level)
          render_ordered_content(terms, level)
        end
      end

      # --- ISO Term rendering ---

      def render_iso_term(term, **_opts)
        attrs = element_attrs(id: safe_attr(term, :id))
        tag("div", attrs) do
          # In presentation mode, use fmt_* elements
          if term.fmt_name
            # Render term number (e.g. "3.1")
            @output << "<p class=\"TermNum\">"
            render_inline_element(term.fmt_name)
            @output << "</p>"
          elsif term.term_number
            tn = term.term_number
            tn_text = if tn.is_a?(String)
                        tn
                      elsif tn.respond_to?(:text)
                        Array(tn.text).join
                      else
                        tn.to_s
                      end
            @output << "<p class=\"TermNum\">#{escape_html(tn_text)}</p>"
          end

          # Preferred designations — use fmt-preferred if available
          if term.fmt_preferred && !term.fmt_preferred.empty?
            term.fmt_preferred.each { |fp| fp.p&.each { |para| render_paragraph(para) } }
          elsif term.preferred && !term.preferred.empty?
            term.preferred&.each { |designation| render_iso_term_designation(designation, "preferred") }
          end

          # Admitted designations — use fmt-admitted if available
          if term.fmt_admitted && !term.fmt_admitted.empty?
            term.fmt_admitted.each { |fa| fa.p&.each { |para| render_paragraph(para) } }
          elsif term.admitted && !term.admitted.empty?
            term.admitted&.each { |designation| render_iso_term_designation(designation, "admitted") }
          end

          # Deprecated designations — use fmt-deprecates if available
          if term.fmt_deprecates
            term.fmt_deprecates.p&.each { |para| render_paragraph(para) }
          elsif term.deprecates && !term.deprecates.empty?
            term.deprecates&.each { |designation| render_iso_term_designation(designation, "deprecated") }
          end

          # Domain
          if term.domain
            domain_text = safe_attr(term.domain, :text)
            @output << "<p class=\"domain\">&lt;#{escape_html(domain_text)}&gt;</p>" if domain_text
          end

          # Definition — use fmt-definition if available
          if term.fmt_definition
            render_ordered_content(term.fmt_definition)
          else
            # Definition paragraphs
            term.p&.each { |para| render_paragraph(para) }
            # Structured definitions
            term.definition&.each { |defn| render_iso_term_definition(defn) }
          end

          # Term notes
          term.termnote&.each { |note| render_iso_term_note(note) }

          # Term examples
          term.termexample&.each { |ex| render_iso_term_example(ex) }

          # Source references — use fmt-termsource if available
          if term.fmt_termsource && !term.fmt_termsource.empty?
            term.fmt_termsource.each do |fts|
              @output << "<p class=\"source\">"
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
          term.term&.each { |sub| render_iso_term(sub) }
        end
      end

      def render_iso_term_designation(designation, type)
        css_class = type == "deprecated" ? "DeprecatedTerms" : "Terms"
        @output << "<p class=\"#{css_class}\" style=\"text-align:left;\">"
        @output << "<del>" if type == "deprecated"
        @output << "<b><dfn>"

        name = extract_iso_designation_name(designation)
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

      def extract_iso_designation_name(designation)
        # Try expression.name first (TermNameElement objects with text)
        expr = designation.expression
        if expr && expr.class.method_defined?(:name) && expr.name
          names = Array(expr.name)
          text = names.map { |n| extract_name_text(n) }.join
          return text unless text.strip.empty?
        end

        # Try text attribute from mixed content
        if designation.class.method_defined?(:text)
          texts = designation.text
          if texts.is_a?(Array)
            joined = texts.join
            return joined unless joined.strip.empty?
          elsif texts.is_a?(String) && !texts.strip.empty?
            return texts
          end
        end

        nil
      end

      def extract_name_text(name_el)
        return name_el.to_s unless name_el.is_a?(Lutaml::Model::Serializable)

        # TermNameElement has text (collection of strings)
        if name_el.class.method_defined?(:text)
          texts = name_el.text
          if texts.is_a?(Array)
            joined = texts.join
            return joined unless joined.strip.empty?
          elsif texts.is_a?(String) && !texts.strip.empty?
            return texts
          end
        end

        ""
      end

      def render_iso_term_definition(definition)
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
        if !rendered && definition.class.method_defined?(:p) && definition.p && !definition.p.empty?
          definition.p.each { |para| render_paragraph(para) }
          rendered = true
        end

        # Fallback: render via element_order
        unless rendered
          render_ordered_content(definition)
        end
      end

      def render_iso_term_note(note)
        attrs = element_attrs(id: safe_attr(note, :id), class: "Note")
        tag("div", attrs) do
          label = extract_termnote_label(note)
          @output << "<p><span class=\"termnote_label\">#{escape_html(label)}: </span>"
          note.p&.each { |para| render_mixed_inline(para) }
          @output << "</p>"
          note.ul&.each { |ul| render_unordered_list(ul) }
          note.ol&.each { |ol| render_ordered_list(ol) }
          note.dl&.then { |dl| render_definition_list(dl) }
        end
      end

      def render_iso_term_example(example)
        attrs = element_attrs(id: safe_attr(example, :id), class: "example")
        tag("div", attrs) do
          label = extract_block_label(example, "EXAMPLE")
          @output << "<p><span class=\"example_label\">#{escape_html(label)}</span>&nbsp;"
          example.p&.each { |para| render_mixed_inline(para) }
          @output << "</p>"
          example.ul&.each { |ul| render_unordered_list(ul) }
          example.ol&.each { |ol| render_ordered_list(ol) }
          example.dl&.then { |dl| render_definition_list(dl) }
        end
      end

      # --- Boilerplate rendering ---

      def render_iso_boilerplate(boilerplate, **_opts)
        return unless boilerplate

        content = boilerplate.content
        return unless content

        @output << "<div class=\"boilerplate-copyright\">"

        raw = content.to_s
        # Strip presentation-only XML elements
        clean = raw
          .gsub(/<fmt-title[^>]*>.*?<\/fmt-title>/m, "")
          .gsub(/<semx[^>]*>.*?<\/semx>/m, "")
          .gsub(/<title[^>]*>.*?<\/title>/m, "")
          .gsub(/<fmt-xref-label[^>]*>.*?<\/fmt-xref-label>/m, "")
          .gsub(/<variant-title[^>]*>.*?<\/variant-title>/m, "")
          .gsub(/<link[^>]*\/>/, "")
          .gsub(/<fmt-link[^>]*\/>/, "")
          .gsub(/<\/?(?:copyright-statement|clause)[^>]*>/, "")

        @output << clean.strip

        @output << "</div>"
      end

      # --- Helpers ---

      def render_iso_title(section, level)
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

      # Collect all renderable children from a section, sorted by displayorder.
      # Uses element_order directly because each_mixed_content returns early
      # when the model class doesn't declare mixed_content (mixed? is false).
      def collect_ordered_children(section)
        children = gather_element_order_children(section)

        # Also gather typed attributes that may not appear in element_order
        %i[terms definitions].each do |attr|
          next unless section.class.method_defined?(attr)
          val = section.public_send(attr)
          next if val.nil?
          Array(val).each do |v|
            children << v unless children.include?(v)
          end
        end

        # Sort by displayorder (non-nil first, then nil at end)
        children.reject!(&:nil?)
        children.sort_by do |node|
          order = node.displayorder rescue nil
          order &&= order.to_i
          order || Float::INFINITY
        end
      end

      def render_ordered_content(section, level = 1)
        children = collect_ordered_children(section)
        children.each do |node|
          next if node.is_a?(String)
          next if is_title_element?(node, section)

          render(node, level: level + 1)
        end
      end

      private

      # Collect all document-level children (sections, normative refs, annexes,
      # bibliography) sorted by displayorder for correct document order.
      def collect_document_children(doc)
        items = []

        # Main sections children (clauses, terms, etc.)
        if doc.sections
          items.concat(gather_element_order_children(doc.sections))
          # Also add typed attributes that may not be in element_order
          %i[terms definitions].each do |attr|
            next unless doc.sections.class.method_defined?(attr)
            val = doc.sections.public_send(attr)
            next if val.nil?
            Array(val).each { |v| items << v unless items.include?(v) }
          end
        end

        # Normative references from bibliography (may have displayorder)
        if doc.bibliography && doc.bibliography.references
          doc.bibliography.references.each { |r| items << r }
        end

        # Annexes
        doc.annex&.each { |a| items << a }

        # Non-normative bibliography (no displayorder = goes at end)
        if doc.bibliography && doc.bibliography.references
          # Already included above; filter normative vs non-normative below
        end

        items.compact!
        items.sort_by do |node|
          order = node.displayorder rescue nil
          order &&= order.to_i
          order || Float::INFINITY
        end
      end

      # Iterate element_order directly, bypassing each_mixed_content which
      # requires mixed?/ordered? to be true (many section models aren't).
      def gather_element_order_children(node)
        children = []
        return children unless node.is_a?(Lutaml::Model::Serializable)
        return children unless node.element_order && !node.element_order.empty?

        xml_mapping = node.class.mappings_for(:xml, node.lutaml_register)
        return children unless xml_mapping

        element_to_attr = {}
        xml_mapping.mapping_elements_hash.each_value do |rule_or_array|
          Array(rule_or_array).each do |rule|
            element_to_attr[rule.name] = rule.to
            element_to_attr[rule.name.to_s] = rule.to if rule.name.is_a?(Symbol)
          end
        end

        indices = Hash.new(0)

        node.element_order.each do |el|
          if el.text?
            children << el.text_content if el.text_content
          elsif el.element?
            attr_name = element_to_attr[el.name]
            next unless attr_name

            coll = node.send(attr_name)
            obj = if coll.is_a?(Array)
                    idx = indices[attr_name]
                    indices[attr_name] += 1
                    coll[idx]
                  else
                    coll
                  end
            children << obj if obj
          end
        end

        children
      end
    end
  end
end
