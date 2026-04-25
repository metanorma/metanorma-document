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

        @output << "</main>"
      end

      def render_coverpage(doc)
        bibdata = doc.bibdata
        return unless bibdata

        @output << "<div class=\"title-section\">"

        # Document identifiers
        bibdata.doc_identifier&.each do |di|
          id = extract_text_value(di)
          next if id.to_s.empty?

          @output << "<p class=\"coverpage_docnumber\">#{escape_html(id)}</p>"
        end

        # Title
        titles = bibdata.respond_to?(:titles) ? bibdata.titles : nil
        if titles && !titles.empty?
          en_title = bibdata.respond_to?(:title_for) ? bibdata.title_for("en") : nil
          if en_title
            @output << "<div class=\"doctitle-en\"><div>"
            @output << "<span class=\"subtitle\">#{escape_html(en_title)}</span>"
            @output << "</div></div>"
          end
        end

        @output << "</div><hr class=\"cover-separator\" />"
      end

      def render_doc_title(doc)
        bibdata = doc.bibdata
        return unless bibdata

        titles = bibdata.respond_to?(:titles) ? bibdata.titles : nil
        return unless titles && !titles.empty?

        en_title = bibdata.respond_to?(:title_for) ? bibdata.title_for("en") : nil
        return unless en_title

        @output << "<p class=\"zzSTDTitle1\">"
        @output << "<span class=\"boldtitle\">#{escape_html(en_title)}</span>"
        @output << "</p>"
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
          terms.terms&.each { |term| render_term(term) } if terms.respond_to?(:terms)
        end
      end

      def render_abstract_section(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_standard_title(section, level, default_class: "IntroTitle")
          render_standard_section_blocks(section, level)
        end
      end

      def render_foreword_section(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_standard_title(section, level, default_class: "ForewordTitle")
          render_standard_section_blocks(section, level)
        end
      end

      def render_introduction_section(section, level: 1, **_opts)
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_standard_title(section, level, default_class: "IntroTitle")
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
          amend.p&.each { |para| render_paragraph(para) } if amend.respond_to?(:p)
          amend.blocks&.each { |block| render(block) } if amend.respond_to?(:blocks)
        end
      end

      # --- Term rendering ---

      def render_term(term, **_opts)
        attrs = element_attrs(id: safe_attr(term, :id))
        tag("div", attrs) do
          # Preferred designations
          term.preferred&.each do |designation|
            render_term_designation(designation, "preferred")
          end

          # Admitted designations
          term.admitted&.each do |designation|
            render_term_designation(designation, "admitted")
          end

          # Deprecated designations
          term.deprecates&.each do |designation|
            render_term_designation(designation, "deprecated")
          end

          # Domain
          if term.respond_to?(:domain) && term.domain
            domain_text = term.domain.is_a?(String) ? term.domain : safe_attr(term.domain, :text).to_s
            @output << "<p class=\"domain\">&lt;#{escape_html(domain_text)}&gt;</p>" unless domain_text.to_s.empty?
          end

          # Definition paragraphs
          if term.respond_to?(:p) && term.p && !term.p.empty?
            term.p.each { |para| render_paragraph(para) }
          end

          # Definitions (structured)
          if term.respond_to?(:definition) && term.definition
            Array(term.definition).each { |defn| render_term_definition(defn) }
          end

          # Term notes
          if term.respond_to?(:termnote) && term.termnote
            term.termnote.each { |note| render_term_note(note) }
          elsif term.respond_to?(:note) && term.note
            Array(term.note).each_with_index do |note, i|
              if note.is_a?(String)
                @output << "<div class=\"Note\"><p><span class=\"termnote_label\">Note #{i + 1} to entry: </span>#{escape_html(note)}</p></div>"
              else
                render_note(note)
              end
            end
          end

          # Term examples
          if term.respond_to?(:termexample) && term.termexample
            term.termexample.each { |ex| render_term_example(ex) }
          elsif term.respond_to?(:example) && term.example
            term.example.each { |ex| render_paragraph(ex) }
          end

          # Source references
          if term.respond_to?(:termsource) && term.termsource
            term.termsource.each { |src| render_term_source_element(src) }
          elsif term.respond_to?(:source) && term.source
            term.source.each { |src| render_term_source(src) }
          end

          # Nested terms
          term.term&.each { |sub| render_term(sub) } if term.respond_to?(:term)
        end
      end

      def render_term_designation(designation, _type)
        name = extract_designation_name(designation)
        return unless name

        tag("p", " class=\"Terms\" style=\"text-align:left;\"") do
          tag("b") do
            tag("dfn") { @output << escape_html(name) }
          end
        end
      end

      def extract_designation_name(designation)
        if designation.respond_to?(:expression) && designation.expression
          expr = designation.expression
          if expr.respond_to?(:name) && expr.name
            Array(expr.name).join
          elsif expr.respond_to?(:text) && expr.text
            Array(expr.text).join
          end
        elsif designation.respond_to?(:name) && designation.name
          Array(designation.name).join
        elsif designation.respond_to?(:text) && designation.text
          Array(designation.text).join
        end
      end

      def render_term_definition(definition)
        return unless definition

        if definition.respond_to?(:p) && definition.p
          Array(definition.p).each { |para| render_paragraph(para) }
        elsif definition.respond_to?(:content)
          @output << "<p>#{escape_html(definition.content.to_s)}</p>"
        end
      end

      def render_term_note(note)
        attrs = element_attrs(id: safe_attr(note, :id), class: "Note")
        tag("div", attrs) do
          label = extract_termnote_label(note)
          @output << "<p><span class=\"termnote_label\">#{escape_html(label)}: </span>"
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
          @output << "<p><span class=\"example_label\">#{escape_html(label)}</span>&nbsp;"
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

        @output << "<p>[SOURCE: "
        if source.respond_to?(:termsource) && source.termsource
          render_mixed_inline(source.termsource)
        elsif source.respond_to?(:origin) && source.origin
          origin = source.origin
          if origin.respond_to?(:citeas)
            @output << escape_html(origin.citeas.to_s)
          else
            render_mixed_inline(origin)
          end
          if source.respond_to?(:modification) && source.modification
            @output << ", modified — #{escape_html(source.modification.to_s)}"
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
          bib.clause&.each { |cl| render(cl, level: level) } if bib.respond_to?(:clause)
        end
      end

      def render_references_section(section, level: 1, **_opts)
        is_normative = safe_attr(section, :normative) == "true"
        attrs = element_attrs(id: safe_attr(section, :id))
        tag("div", attrs) do
          render_standard_title(section, level, default_class: is_normative ? "" : "Section3")
          section.p&.each { |para| render_paragraph(para) }
          section.note&.each { |note| render_paragraph(note) } if section.respond_to?(:note)
          section.references&.each_with_index { |bibitem, i| render_bibitem(bibitem, i + 1) }
          section.table&.each { |t| render_table(t) }
        end
      end

      def render_bibitem(item, index)
        attrs = element_attrs(id: safe_attr(item, :id), class: "Biblio")
        tag("p", attrs) do
          # Use biblio-tag from presentation XML if available
          if item.biblio_tag
            render_mixed_inline(item.biblio_tag)
            @output << "&nbsp;"
          else
            @output << "[#{index}]&nbsp;"
          end

          render_bibitem_content(item)
        end
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
            @output << "<span class=\"stddocNumber\">#{escape_html(id_val)}</span>" unless id_val.to_s.empty?
          end
        end

        if item.date && !item.date.empty?
          Array(item.date).each do |date|
            date_on = date.respond_to?(:on) ? date.on : nil
            date_val = extract_text_value(date_on || safe_attr(date, :text))
            if date_val && !date_val.to_s.empty?
              @output << ":<span class=\"stdyear\">#{escape_html(date_val.to_s)}</span>"
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

        h = "h#{[[level, 6].min, 1].max}"
        title_class = default_class.empty? ? "" : " class=\"#{default_class}\""
        @output << "<#{h}#{title_class}>"
        render_mixed_inline(title_element)
        @output << "</#{h}>"
      end

      def render_standard_section_blocks(section, level)
        if section.respond_to?(:each_mixed_content)
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
        paragraphs = section.respond_to?(:paragraphs) ? section.paragraphs : section.p
        Array(paragraphs).each { |p| render_paragraph(p) } if paragraphs

        # Lists
        Array(section.unordered_lists).each { |ul| render_unordered_list(ul) } if section.respond_to?(:unordered_lists)
        Array(section.ordered_lists).each { |ol| render_ordered_list(ol) } if section.respond_to?(:ordered_lists)
        Array(section.definition_lists).each { |dl| render_definition_list(dl) } if section.respond_to?(:definition_lists)

        # Tables, figures, formulas, examples, etc.
        Array(section.tables).each { |t| render_table(t) } if section.respond_to?(:tables)
        Array(section.figures).each { |f| render_figure(f) } if section.respond_to?(:figures)
        Array(section.formulas).each { |f| render_formula(f) } if section.respond_to?(:formulas)
        Array(section.examples).each { |e| render_example(e) } if section.respond_to?(:examples)
        Array(section.notes).each { |n| render_note(n) } if section.respond_to?(:notes)
        Array(section.admonitions).each { |a| render_admonition(a) } if section.respond_to?(:admonitions)
        Array(section.sourcecode_blocks).each { |s| render_sourcecode(s) } if section.respond_to?(:sourcecode_blocks)
        Array(section.quote_blocks).each { |q| render_quote(q) } if section.respond_to?(:quote_blocks)
      end

      def render_subsections(section, level)
        return unless section.respond_to?(:clause)

        Array(section.clause).each { |cl| render(cl, level: level + 1) }
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
