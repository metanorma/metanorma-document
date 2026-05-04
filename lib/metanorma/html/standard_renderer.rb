# frozen_string_literal: true

module Metanorma
  module Html
    # Renders StandardDocument components to HTML.
    # Extends BaseRenderer with terms, bibliography, and standard sections.
    class StandardRenderer < BaseRenderer
      def render(node, **opts)
        case node
        when Metanorma::StandardDocument::Root
          render_standard_document(node, **opts)
        when Metanorma::StandardDocument::Terms::Term
          render_term(node, **opts)
        when Metanorma::StandardDocument::Sections::TermsSection
          render_terms_section(node, **opts)
        when Metanorma::StandardDocument::Sections::StandardReferencesSection
          render_references_section(node, **opts)
        when Metanorma::StandardDocument::Sections::BibliographySection
          render_bibliography(node, **opts)
        when Metanorma::StandardDocument::Sections::ClauseSection
          render_clause_section(node, **opts)
        when Metanorma::StandardDocument::Sections::AnnexSection
          render_annex_section(node, **opts)
        when Metanorma::StandardDocument::Sections::StandardSection
          render_standard_section(node, **opts)
        when Metanorma::StandardDocument::Sections::Abstract
          render_abstract_section(node, **opts)
        when Metanorma::StandardDocument::Sections::Foreword
          render_foreword_section(node, **opts)
        when Metanorma::StandardDocument::Sections::Introduction
          render_introduction_section(node, **opts)
        when Metanorma::StandardDocument::Sections::FloatingTitle
          render_floating_title(node, **opts)
        when Metanorma::StandardDocument::Blocks::AmendBlock
          render_amend_block(node, **opts)
        else
          super
        end
      end

      private

      # --- Top-level document rendering ---

      def render_standard_document(doc, **_opts)
        render_coverpage(doc)

        @output << "<main class=\"main-section\">"

        # Preface sections
        render(doc.preface) if doc.preface

        # Document title line
        render_doc_title(doc)

        # Main sections
        render(doc.sections) if doc.sections

        # Annexes
        doc.annex&.each { |annex| render(annex) }

        # Bibliography
        render(doc.bibliography) if doc.bibliography

        # Index section (from collected index terms)
        unless @index_term_collector.empty?
          index_component = Component::IndexSection.new(self)
          index_component.render(@index_term_collector)
        end

        # Index section from indexsect element (presentation XML)
        if doc.respond_to?(:indexsect) && doc.indexsect
          render(doc.indexsect)
        end

        # Footnotes section
        render_footnotes_section

        @output << "</main>"
      end

      def render_coverpage(doc)
        bibdata = doc.bibdata
        return unless bibdata

        cover_id = nil
        bibdata.doc_identifier&.each do |di|
          next unless safe_attr(di, :type) == "iso-reference"
          id = extract_text_value(di)
          next if id.to_s.empty?
          cover_id = id
          break
        end

        title_text = nil
        if bibdata.is_a?(Metanorma::IsoDocument::Metadata::IsoBibliographicItem)
          en_title = bibdata.title_for("en")
          title_text = en_title.to_s if en_title
        elsif bibdata.is_a?(Metanorma::Document::Components::BibData::BibData)
          titles = bibdata.title
          if titles && !titles.empty?
            en_title = titles.find { |t| t.language == "en" }
            title_text = extract_text_value(en_title) if en_title
          end
        end

        @output << render_liquid("_cover.html.liquid", {
          "doc_id" => cover_id,
          "title" => title_text,
        })
      end

      def render_doc_title(doc)
        bibdata = doc.bibdata
        return unless bibdata

        if bibdata.is_a?(Metanorma::IsoDocument::Metadata::IsoBibliographicItem)
          en_title = bibdata.title_for("en")
          return unless en_title
        elsif bibdata.is_a?(Metanorma::Document::Components::BibData::BibData)
          titles = bibdata.title
          return unless titles && !titles.empty?
          en_title = titles.find { |t| t.language == "en" }
          return unless en_title
          en_title = extract_text_value(en_title)
        else
          return
        end

        @output << render_liquid("_doc_title.html.liquid", {
          "title" => en_title,
        })
      end

      # --- Section rendering ---

      def render_clause_section(clause, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(clause, :id), class: safe_attr(clause, :class_attr))
        tag("div", attrs) do
          render_standard_title(clause, level)
          render_standard_section_blocks(clause, level)
          render_subsections(clause, level)
        end
      end

      def render_annex_section(annex, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(annex, :id))
        tag("div", attrs) do
          render_standard_title(annex, level)
          render_standard_section_blocks(annex, level)
          render_subsections(annex, level)
        end
      end

      def render_standard_section(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_standard_title(section, level)
          render_standard_section_blocks(section, level)
        end
      end

      def render_terms_section(terms, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(terms, :id))
        tag("div", attrs) do
          render_standard_title(terms, level)
          render_standard_section_blocks(terms, level)
          terms.terms&.each { |term| render_term(term) }
        end
      end

      def render_abstract_section(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_standard_title(section, level, default_class: "intro-title")
          render_standard_section_blocks(section, level)
        end
      end

      def render_foreword_section(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_standard_title(section, level, default_class: "foreword-title")
          render_standard_section_blocks(section, level)
        end
      end

      def render_introduction_section(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_standard_title(section, level, default_class: "intro-title")
          render_standard_section_blocks(section, level)
        end
      end

      def render_floating_title(title_node, **_opts)
        level = safe_attr(title_node, :level) || 1
        h = "h#{[[level, 6].min, 1].max}"
        attrs = element_attrs(id: safe_attr(title_node, :id))
        @output << "<#{h}#{attrs}>#{escape_html(title_node.text.to_s)}</#{h}>"
      end

      def render_amend_block(amend, **_opts)
        attrs = element_attrs(id: safe_attr(amend, :id))
        tag("div", attrs) do
          render_mixed_inline(amend)
        end
      end

      # --- Term rendering ---

      def render_term(term, **_opts)
        attrs = element_attrs(id: safe_attr(term, :id))
        tag("div", attrs) do
          term.preferred&.each { |d| render_term_designation(d, "preferred") }
          term.admitted&.each { |d| render_term_designation(d, "admitted") }
          term.deprecates&.each { |d| render_term_designation(d, "deprecated") }

          # Domain
          if term.domain
            domain_text = term.domain.is_a?(String) ? term.domain : safe_attr(term.domain, :text).to_s
            @output << "<p class=\"term-domain\">&lt;#{escape_html(domain_text)}&gt;</p>" unless domain_text.to_s.empty?
          end

          # Definitions
          Array(term.definition).each { |defn| render_term_definition(defn) } if term.definition

          # Notes (mapped from <termnote>)
          term.note&.each_with_index do |note, i|
            if note.is_a?(String)
              @output << "<div class=\"note-block\"><p><span class=\"term-note-label\">Note #{i + 1} to entry: </span>#{escape_html(note)}</p></div>"
            else
              render_note(note)
            end
          end

          # Examples (mapped from <termexample>)
          term.example&.each { |ex| render_paragraph(ex) }

          # Source references
          term.source&.each { |src| render_term_source(src) }
        end
      end

      def render_term_designation(designation, _type)
        name = extract_designation_name(designation)
        return unless name

        tag("p", " class=\"term-name\" style=\"text-align:left;\"") do
          tag("b") do
            tag("dfn") { @output << escape_html(name) }
          end
        end
      end

      def extract_designation_name(designation)
        if designation.is_a?(Metanorma::StandardDocument::Terms::Designation) && designation.expression
          expr = designation.expression
          if expr.is_a?(Metanorma::IsoDocument::Terms::TermExpression) && expr.name
            Array(expr.name).join
          end
        elsif designation.is_a?(Metanorma::IsoDocument::Terms::TermExpression) && designation.name
          Array(designation.name).join
        else
          extract_text_value(designation)
        end
      end

      def render_term_definition(definition)
        return unless definition
        return unless definition.is_a?(Metanorma::StandardDocument::Terms::TermDefinition)

        ve = definition.verbalexpression
        return unless ve

        ve.paragraph&.each { |para| render_paragraph(para) }
      end

      def render_term_note(note)
        attrs = element_attrs(id: safe_attr(note, :id), class: "note-block")
        tag("div", attrs) do
          label = extract_termnote_label(note)
          @output << "<p><span class=\"term-note-label\">#{escape_html(label)}: </span>"
          if note.p && !note.p.empty?
            note.p.each do |para|
              render_mixed_inline(para)
            end
          end
          @output << "</p>"
          note.ul&.each { |ul| render_unordered_list(ul) }
          note.ol&.each { |ol| render_ordered_list(ol) }
          note.dl&.then { |dl| render_definition_list(dl) }
        end
      end

      def render_term_example(example)
        attrs = element_attrs(id: safe_attr(example, :id), class: "example")
        tag("div", attrs) do
          label = extract_block_label(example, "EXAMPLE")
          @output << "<p><span class=\"example-label\">#{escape_html(label)}</span>&nbsp;"
          if example.p && !example.p.empty?
            example.p.each do |para|
              render_mixed_inline(para)
            end
          end
          @output << "</p>"
          example.ul&.each { |ul| render_unordered_list(ul) }
          example.ol&.each { |ol| render_ordered_list(ol) }
          example.dl&.then { |dl| render_definition_list(dl) }
        end
      end

      def render_term_source(source)
        return unless source

        @output << "<p class=\"term-source\">[SOURCE: "
        termsource = safe_attr(source, :termsource)
        origin = safe_attr(source, :origin)

        if termsource
          render_mixed_inline(termsource)
        elsif origin
          citeas = safe_attr(origin, :citeas)
          bibitemid = safe_attr(origin, :bibitemid)

          if citeas && !citeas.to_s.empty?
            if bibitemid && !bibitemid.to_s.empty?
              @output << "<a href=\"##{escape_html(bibitemid.to_s)}\" class=\"bibref\">#{escape_html(citeas.to_s)}</a>"
            else
              @output << escape_html(citeas.to_s)
            end
          else
            render_mixed_inline(origin)
          end

          modification = safe_attr(source, :modification)
          if modification && !modification.to_s.empty?
            @output << ", modified — #{escape_html(modification.to_s)}"
          end
        else
          render_mixed_inline(source)
        end
        @output << "]</p>"
      end

      def render_term_source_element(element)
        return unless element

        @output << "<p>"
        render_mixed_inline(element)
        @output << "</p>"
      end

      # --- Bibliography / References ---

      def render_bibliography(bib, level: 1, **_opts)
        tag("div", "") do
          bib.references&.each { |ref| render_references_section(ref, level: level) }
          bib.clause&.each { |cl| render(cl, level: level) }
        end
      end

      def render_references_section(section, level: 1, **_opts)
        is_normative = safe_attr(section, :normative) == "true"
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_standard_title(section, level, default_class: is_normative ? "" : "section-sub")
          section.p&.each { |para| render_paragraph(para) }
          section.note&.each { |note| render_paragraph(note) }
          section.references&.each_with_index { |bibitem, i| render_bibitem(bibitem, i + 1, normative: is_normative) }
          section.table&.each { |t| render_table(t) }
        end
      end

      def render_bibitem(item, index, normative: false)
        css_class = normative ? "norm-ref-entry" : "biblio-entry"
        attrs = element_attrs(id: safe_attr(item, :id), class: css_class)
        url = bibitem_url(item)

        tag("p", attrs) do
          if url
            @output << "<a href=\"#{escape_html(url)}\" target=\"_blank\" rel=\"noopener\" class=\"biblio-link\">"
          end

          # Use biblio-tag from presentation XML if available
          if item.biblio_tag
            render_mixed_inline(item.biblio_tag)
            @output << "&nbsp;"
          else
            @output << "[#{index}]&nbsp;"
          end

          render_bibitem_content(item)

          if url
            @output << "</a>"
          end
        end
      end

      def bibitem_url(item)
        links = Array(item.link)
        return nil if links.empty?
        # Prefer src or citation type, skip RSS feeds
        preferred = links.find { |l| l.type == "src" || l.type == "citation" }
        return preferred.content.to_s if preferred && !preferred.content.to_s.empty?
        # Fallback: first non-RSS link
        non_rss = links.find { |l| !l.content.to_s.include?(".rss") && !l.content.to_s.empty? }
        non_rss&.content&.to_s
      end

      def render_bibitem_content(item)
        # Use formatted reference if available (presentation XML)
        if item.formatted_ref
          render_mixed_inline(item.formatted_ref)
          return
        end

        # Fallback: construct from parts
        if item.docidentifier && !item.docidentifier.empty?
          docids = Array(item.docidentifier)
          # Skip bracket-number identifiers (e.g. "[1]") and iso-reference/URN variants;
          # render only the primary doc identifier
          primary = docids.find { |di|
            val = extract_text_value(di).to_s
            val.match?(/\A\[?\d+\]?\z/) ? false : !val.match?(/\A(?:iso-reference|URN)\s/)
          }
          if primary
            id_val = extract_text_value(primary)
            @output << "<span class=\"std-doc-number\">#{escape_html(id_val)}</span>" unless id_val.to_s.empty?
          end
        end

        if item.date && !item.date.empty?
          Array(item.date).each do |date|
            date_on = date.is_a?(Metanorma::Document::Relaton::BibliographicDate) ? date.on : nil
            date_val = extract_text_value(date_on || safe_attr(date, :text))
            if date_val && !date_val.to_s.empty?
              @output << ":<span class=\"std-year\">#{escape_html(date_val.to_s)}</span>"
            end
          end
        end

        if item.title && !item.title.empty?
          titles = Array(item.title)
          main_title = titles.find { |t| safe_attr(t, :type) == "main" } || titles.first
          if main_title
            @output << ", <i>"
            render_mixed_inline(main_title)
            @output << "</i>"
          end
        end
      end

      # --- Standard section helpers ---

      def render_standard_title(section, level, default_class: "")
        title_element = safe_attr(section, :fmt_title) || safe_attr(section, :title)
        return unless title_element

        section_id = safe_attr(section, :id)
        title_text = extract_plain_text(title_element)
        register_toc_entry(id: section_id, level: level, text: title_text)

        @current_section_id = section_id
        @current_section_number = title_text

        h = "h#{[[level, 6].min, 1].max}"
        title_class = default_class.empty? ? "" : " class=\"#{default_class}\""
        @output << "<#{h}#{title_class}>"
        render_mixed_inline(title_element)
        @output << "</#{h}>"
      end

      def render_standard_section_blocks(section, level)
        if section.is_a?(Lutaml::Model::Serializable) && section.mixed?
          section.each_mixed_content do |node|
            next if node.is_a?(String)
            next if is_title_element?(node, section)

            render(node, level: level + 1)
          end
        else
          render_section_block_collections(section, level)
        end
      end

      def render_section_block_collections(section, level)
        # Paragraphs
        paragraphs = safe_attr(section, :paragraphs) || safe_attr(section, :p)
        Array(paragraphs).each { |p| render_paragraph(p) } if paragraphs

        # Lists
        %i[unordered_lists ordered_lists definition_lists].each do |attr|
          values = safe_attr(section, attr)
          Array(values).each { |v| render(v, level: level + 1) } if values
        end

        # Block elements
        %i[tables figures formulas examples notes admonitions sourcecode_blocks quote_blocks].each do |attr|
          values = safe_attr(section, attr)
          Array(values).each { |v| render(v, level: level + 1) } if values
        end
      end

      def render_subsections(section, level)
        clauses = safe_attr(section, :clause) || safe_attr(section, :subsections)
        Array(clauses).each { |cl| render(cl, level: level + 1) } if clauses
      end

      def is_title_element?(node, section)
        title = safe_attr(section, :title)
        return false unless title

        node.equal?(title)
      end

      def extract_termnote_label(note)
        # Presentation XML: <name>Note 1 to entry</name>
        names = safe_attr(note, :name)
        if names && !names.empty?
          name = names.is_a?(Array) ? names.first : names
          text = extract_text_value(name)
          return text unless text.to_s.strip.empty?
        end

        # Fallback: autonum attribute
        autonum = safe_attr(note, :autonum)
        return "Note #{autonum} to entry" if autonum && !autonum.to_s.empty?

        "Note to entry"
      end
    end
  end
end
