# frozen_string_literal: true

module Metanorma
  module Html
    class StandardRenderer < BaseRenderer
      register_render Metanorma::StandardDocument::Root,
                      :render_standard_document
      register_render Metanorma::StandardDocument::Terms::Term, :render_term
      register_render Metanorma::StandardDocument::Sections::TermsSection,
                      :render_terms_section
      register_render Metanorma::StandardDocument::Sections::StandardReferencesSection,
                      :render_references_section
      register_render Metanorma::StandardDocument::Sections::BibliographySection,
                      :render_bibliography
      register_render Metanorma::StandardDocument::Sections::ClauseSection,
                      :render_clause_section
      register_render Metanorma::StandardDocument::Sections::AnnexSection,
                      :render_annex_section
      register_render Metanorma::StandardDocument::Sections::StandardSection,
                      :render_standard_section
      register_render Metanorma::StandardDocument::Sections::Abstract,
                      :render_abstract_section
      register_render Metanorma::StandardDocument::Sections::Foreword,
                      :render_foreword_section
      register_render Metanorma::StandardDocument::Sections::Introduction,
                      :render_introduction_section
      register_render Metanorma::StandardDocument::Sections::FloatingTitle,
                      :render_floating_title
      register_render Metanorma::StandardDocument::Blocks::AmendBlock,
                      :render_amend_block

      def render_standard_document(doc, **_opts)
        cover = render_coverpage(doc)

        content_parts = []
        content_parts << (render(doc.preface) || "") if doc.preface
        content_parts << (render_doc_title(doc) || "")
        content_parts << (render(doc.sections) || "") if doc.sections
        doc.annex&.each { |annex| content_parts << (render(annex) || "") }
        content_parts << (render(doc.bibliography) || "") if doc.bibliography

        unless @index_term_collector.empty?
          index_component = Component::IndexSection.new(self)
          content_parts << (index_component.render(@index_term_collector) || "")
        end

        content_parts << (render(doc.indexsect) || "") if doc.indexsect
        content_parts << (render_footnotes_section || "")

        cover + render_liquid("_main_content.html.liquid", {
                                "content" => content_parts.join,
                              })
      end

      def render_coverpage(doc)
        bibdata = doc.bibdata
        return "" unless bibdata

        cover_id = nil
        bibdata.doc_identifier&.each do |di|
          next unless safe_attr(di, :type) == "iso-reference"

          id = extract_text_value(di)
          next if id.to_s.empty?

          cover_id = id
          break
        end

        title_text = extract_display_title(bibdata)

        render_liquid("_cover.html.liquid", {
                        "doc_id" => cover_id,
                        "title" => title_text,
                      })
      end

      def render_doc_title(doc)
        bibdata = doc.bibdata
        return nil unless bibdata

        title = extract_display_title(bibdata)
        return nil unless title

        render_liquid("_doc_title.html.liquid", {
                        "title" => title,
                      })
      end

      def render_section(section, level: 1, title_class: nil,
        with_subsections: false, with_terms: false)
        attrs = element_attrs(id: safe_attr(section, :id))
        parts = []
        parts << if title_class
                   render_standard_title(section, level,
                                         default_class: title_class) || ""
                 else
                   render_standard_title(section, level) || ""
                 end
        parts << (render_standard_section_blocks(section, level) || "")
        parts << (render_subsections(section, level) || "") if with_subsections
        if with_terms
          section.terms&.each { |term| parts << (render_term(term) || "") }
        end
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => attrs,
                        "content" => parts.join,
                      })
      end

      def render_clause_section(section, level: 1, **)
        render_section(section, level: level, with_subsections: true)
      end

      def render_annex_section(section, level: 1, **)
        render_section(section, level: level, with_subsections: true)
      end

      def render_standard_section(section, level: 1, **)
        render_section(section, level: level)
      end

      def render_terms_section(section, level: 1, **)
        render_section(section, level: level, with_terms: true)
      end

      def render_abstract_section(section, level: 1, **)
        render_section(section, level: level, title_class: "intro-title")
      end

      def render_foreword_section(section, level: 1, **)
        render_section(section, level: level, title_class: "foreword-title")
      end

      def render_introduction_section(section, level: 1, **)
        render_section(section, level: level, title_class: "intro-title")
      end

      def render_floating_title(title_node, **_opts)
        level = safe_attr(title_node, :level) || 1
        h = "h#{[[level, 6].min, 1].max}"
        attrs = element_attrs(id: safe_attr(title_node, :id))
        render_liquid("_heading.html.liquid", {
                        "tag" => h,
                        "class_attr" => attrs,
                        "content" => escape_html(title_node.text.to_s),
                      })
      end

      def render_amend_block(amend, **_opts)
        attrs = element_attrs(id: safe_attr(amend, :id))
        content = render_mixed_inline(amend)
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => attrs,
                        "content" => content,
                      })
      end

      # --- Term rendering ---

      def render_term(term, **_opts)
        attrs = element_attrs(id: safe_attr(term, :id))
        parts = []
        term.preferred&.each do |d|
          parts << (render_term_designation(d, "preferred") || "")
        end
        term.admitted&.each do |d|
          parts << (render_term_designation(d, "admitted") || "")
        end
        term.deprecates&.each do |d|
          parts << (render_term_designation(d, "deprecated") || "")
        end

        if term.domain
          domain_text = if term.domain.is_a?(String)
                          term.domain
                        else
                          safe_attr(term.domain, :text).to_s
                        end
          unless domain_text.to_s.empty?
            parts << render_liquid("_term_domain.html.liquid", {
                                     "text" => escape_html(domain_text),
                                   }).to_s
          end
        end

        if term.definition
          Array(term.definition).each do |defn|
            parts << (render_term_definition(defn) || "")
          end
        end

        term.note&.each_with_index do |note, i|
          if note.is_a?(String)
            label = "Note #{i + 1} to entry: "
            parts << render_liquid("_term_text_note.html.liquid", {
                                     "label" => label,
                                     "content" => escape_html(note),
                                   }).to_s
          else
            parts << (render_note(note) || "")
          end
        end

        term.example&.each { |ex| parts << (render_paragraph(ex) || "") }
        term.source&.each { |src| parts << (render_term_source(src) || "") }
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => attrs,
                        "content" => parts.join,
                      })
      end

      def render_term_designation(designation, _type)
        name = extract_designation_name(designation)
        return nil unless name

        inner = escape_html(name)
        dfn = render_liquid("_element.html.liquid",
                            { "tag" => "dfn", "extra_attrs" => "",
                              "content" => inner })
        bold = render_liquid("_element.html.liquid",
                             { "tag" => "b", "extra_attrs" => "",
                               "content" => dfn })
        render_liquid("_element.html.liquid", {
                        "tag" => "p",
                        "extra_attrs" => " class=\"term-name\" style=\"text-align:left;\"",
                        "content" => bold,
                      })
      end

      def extract_designation_name(designation)
        if designation.is_a?(Metanorma::StandardDocument::Terms::Designation) && designation.expression
          expr = designation.expression
          if expr.is_a?(Metanorma::StandardDocument::Terms::TermExpression) && expr.name
            Array(expr.name).join
          end
        elsif designation.is_a?(Metanorma::StandardDocument::Terms::TermExpression) && designation.name
          Array(designation.name).join
        else
          extract_text_value(designation)
        end
      end

      def render_term_definition(definition)
        return nil unless definition
        return nil unless definition.is_a?(Metanorma::StandardDocument::Terms::TermDefinition)

        ve = definition.verbalexpression
        return nil unless ve

        parts = []
        ve.paragraph&.each { |para| parts << (render_paragraph(para) || "") }
        parts.join
      end

      def render_term_note(note)
        attrs = element_attrs(id: safe_attr(note, :id), class: "note-block")
        label = extract_termnote_label(note)
        parts = []
        note_content_parts = []
        note.p&.each do |para|
          note_content_parts << (render_mixed_inline(para) || "")
        end
        note_content = note_content_parts.join
        parts << render_liquid("_term_note.html.liquid", {
                                 "label" => escape_html(label),
                                 "content" => note_content,
                               })
        note.ul&.each { |ul| parts << (render_unordered_list(ul) || "") }
        note.ol&.each { |ol| parts << (render_ordered_list(ol) || "") }
        note.dl&.then { |dl| parts << (render_definition_list(dl) || "") }
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => attrs,
                        "content" => parts.join,
                      })
      end

      def render_term_example(example)
        attrs = element_attrs(id: safe_attr(example, :id), class: "example")
        label = extract_block_label(example, "EXAMPLE")
        parts = []
        ex_content_parts = []
        example.p&.each do |para|
          ex_content_parts << (render_mixed_inline(para) || "")
        end
        ex_content = ex_content_parts.join
        parts << render_liquid("_term_example.html.liquid", {
                                 "label" => escape_html(label),
                                 "content" => ex_content,
                               })
        example.ul&.each { |ul| parts << (render_unordered_list(ul) || "") }
        example.ol&.each { |ol| parts << (render_ordered_list(ol) || "") }
        example.dl&.then { |dl| parts << (render_definition_list(dl) || "") }
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => attrs,
                        "content" => parts.join,
                      })
      end

      def render_term_source(source)
        return nil unless source

        parts = []
        termsource = safe_attr(source, :termsource)
        origin = safe_attr(source, :origin)

        if termsource
          parts << (render_mixed_inline(termsource) || "")
        elsif origin
          citeas = safe_attr(origin, :citeas)
          bibitemid = safe_attr(origin, :bibitemid)

          parts << if citeas && !citeas.to_s.empty?
                     if bibitemid && !bibitemid.to_s.empty?
                       render_liquid("_link.html.liquid", {
                                       "attrs" => element_attrs(
                                         href: "##{escape_html(bibitemid.to_s)}", class: "bibref",
                                       ),
                                       "content" => escape_html(citeas.to_s),
                                     })
                     else
                       escape_html(citeas.to_s)
                     end
                   else
                     render_mixed_inline(origin) || ""
                   end

          modification = safe_attr(source, :modification)
          if modification && !modification.to_s.empty?
            parts << ", modified — #{escape_html(modification.to_s)}"
          end
        else
          parts << (render_mixed_inline(source) || "")
        end

        render_liquid("_term_source.html.liquid", {
                        "content" => parts.join,
                      })
      end

      def render_term_source_element(element)
        return nil unless element

        content = render_mixed_inline(element)
        render_liquid("_paragraph.html.liquid", {
                        "attrs" => "",
                        "content" => content,
                      })
      end

      # --- Bibliography / References ---

      def render_bibliography(bib, level: 1, **_opts)
        parts = []
        bib.references&.each do |ref|
          parts << (render_references_section(ref, level: level) || "")
        end
        bib.clause&.each { |cl| parts << (render(cl, level: level) || "") }
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => "",
                        "content" => parts.join,
                      })
      end

      def render_references_section(section, level: 1, **_opts)
        is_normative = safe_attr(section, :normative) == "true"
        attrs = element_attrs(id: safe_attr(section, :id))
        parts = []
        parts << (render_standard_title(section, level,
                                        default_class: is_normative ? "" : "section-sub") || "")
        section.p&.each { |para| parts << (render_paragraph(para) || "") }
        section.note&.each { |note| parts << (render_paragraph(note) || "") }
        section.references&.each_with_index do |bibitem, i|
          parts << (render_bibitem(bibitem, i + 1,
                                   normative: is_normative) || "")
        end
        section.table&.each { |t| parts << (render_table(t) || "") }
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => attrs,
                        "content" => parts.join,
                      })
      end

      def render_bibitem(item, index, normative: false)
        css_class = normative ? "norm-ref-entry" : "biblio-entry"
        item_id = safe_attr(item, :id)
        url = bibitem_url(item)

        if item.biblio_tag
          prefix, rest = split_biblio_tag(item.biblio_tag)
          ordinal_html = prefix.empty? ? nil : escape_html(prefix)
          pubid_html = rest&.filter_map do |child|
            render_inline_element(child)
          end&.join
        else
          ordinal_html = "[#{index}]"
          pubid_html = nil
        end

        content_html = render_bibitem_content(item)

        drop = Drops::BiblioEntryDrop.new(
          id: item_id,
          css_class: css_class,
          ordinal_html: ordinal_html,
          pubid_html: pubid_html,
          url: url ? escape_html(url) : nil,
          content_html: content_html,
        )
        render_liquid("_biblio_entry.html.liquid", { "entry" => drop })
      end

      def split_biblio_tag(tag)
        children = []
        tag.each_mixed_content { |c| children << c }

        prefix = +""
        rest = []
        found_boundary = false

        children.each do |child|
          if found_boundary
            rest << child
          else
            case child
            when Metanorma::Document::Components::Inline::TabElement
              found_boundary = true
              next
            when String
              stripped = child.strip
              if stripped.match?(/\A\[\d+\]\z/)
                prefix << child
              elsif child.match?(/\A\s*\z/)
                prefix << child
              else
                found_boundary = true
                rest << child
              end
            else
              found_boundary = true
              rest << child
            end
          end
        end

        prefix_text = prefix.strip
        [prefix_text, rest.empty? ? nil : rest]
      end

      def bibitem_url(item)
        links = Array(item.link)
        return nil if links.empty?

        preferred = links.find { |l| ["src", "citation"].include?(l.type) }
        return preferred.content.to_s if preferred && !preferred.content.to_s.empty?

        non_rss = links.find do |l|
          !l.content.to_s.include?(".rss") && !l.content.to_s.empty?
        end
        non_rss&.content&.to_s
      end

      def render_bibitem_content(item)
        parts = []
        if item.formatted_ref
          parts << (render_mixed_inline(item.formatted_ref) || "")
          return parts.join
        end

        rendered_pubid = render_pubid_identifier(item)
        unless rendered_pubid
          render_docidentifier_fallback_into(parts, item)
        end

        if item.date && !item.date.empty?
          Array(item.date).each do |date|
            date_on = date.is_a?(Metanorma::Document::Relaton::BibliographicDate) ? date.on : nil
            date_val = extract_text_value(date_on || safe_attr(date, :text))
            if date_val && !date_val.to_s.empty?
              parts << render_liquid("_ref_date.html.liquid", {
                                       "prefix" => ":",
                                       "year" => escape_html(date_val.to_s),
                                     })
            end
          end
        end

        if item.title && !item.title.empty?
          titles = Array(item.title)
          main_title = titles.find do |t|
            safe_attr(t, :type) == "main"
          end || titles.first
          if main_title
            title_content = render_mixed_inline(main_title)
            parts << render_liquid("_ref_title.html.liquid", {
                                     "content" => title_content,
                                   })
          end
        end
        parts.join
      end

      def render_pubid_identifier(item)
        return nil unless item.docidentifier && !item.docidentifier.empty?

        docids = Array(item.docidentifier)
        primary = docids.find do |di|
          val = extract_text_value(di).to_s
          val.match?(/\A\[?\d+\]?\z/) ? false : !val.match?(/\A(?:iso-reference|URN)\s/)
        end
        return nil unless primary

        id_string = extract_text_value(primary).to_s
        return nil if id_string.empty?

        identifier = parse_pubid(id_string)
        return nil unless identifier

        pubid_to_html(identifier)
      end

      def render_docidentifier_fallback_into(parts, item)
        return unless item.docidentifier && !item.docidentifier.empty?

        docids = Array(item.docidentifier)
        primary = docids.find do |di|
          val = extract_text_value(di).to_s
          val.match?(/\A\[?\d+\]?\z/) ? false : !val.match?(/\A(?:iso-reference|URN)\s/)
        end
        return unless primary

        id_val = extract_text_value(primary)
        unless id_val.to_s.empty?
          parts << render_liquid("_inline_span.html.liquid", {
                                   "attrs" => " class=\"ref-doc-number\"",
                                   "content" => escape_html(id_val),
                                 })
        end
      end

      # --- Standard section helpers ---

      def render_standard_title(section, level, default_class: "")
        title_element = safe_attr(section,
                                  :fmt_title) || safe_attr(section, :title)
        return nil unless title_element

        section_id = safe_attr(section, :id)
        title_content = render_mixed_inline(title_element)
        title_text = extract_plain_text(title_element)
        register_toc_entry(id: section_id, level: level, text: title_text)

        @current_section_id = section_id
        @current_section_number = title_text

        h = "h#{[[level, 6].min, 1].max}"
        title_class = default_class.empty? ? "" : " class=\"#{default_class}\""
        render_liquid("_heading.html.liquid", {
                        "tag" => h,
                        "class_attr" => title_class,
                        "content" => title_content,
                      })
      end

      def render_standard_section_blocks(section, level)
        if section.is_a?(Lutaml::Model::Serializable) && section.mixed?
          parts = []
          section.each_mixed_content do |node|
            next if node.is_a?(String)
            next if is_title_element?(node, section)

            parts << (render(node, level: level + 1) || "")
          end
          parts.join
        else
          render_section_block_collections(section, level)
        end
      end

      def render_section_block_collections(section, level)
        parts = []
        paragraphs = safe_attr(section, :paragraphs) || safe_attr(section, :p)
        if paragraphs
          Array(paragraphs).each do |p|
            parts << (render_paragraph(p) || "")
          end
        end

        %i[unordered_lists ordered_lists definition_lists].each do |attr|
          values = safe_attr(section, attr)
          if values
            Array(values).each do |v|
              parts << (render(v, level: level + 1) || "")
            end
          end
        end

        %i[tables figures formulas examples notes admonitions sourcecode_blocks
           quote_blocks].each do |attr|
          values = safe_attr(section, attr)
          if values
            Array(values).each do |v|
              parts << (render(v, level: level + 1) || "")
            end
          end
        end
        parts.join
      end

      def render_subsections(section, level)
        clauses = safe_attr(section,
                            :clause) || safe_attr(section, :subsections)
        return nil unless clauses

        clauses.filter_map { |cl| render(cl, level: level + 1) }.join
      end

      def extract_termnote_label(note)
        names = safe_attr(note, :name)
        if names && !names.empty?
          name = names.is_a?(Array) ? names.first : names
          text = extract_text_value(name)
          return text unless text.to_s.strip.empty?
        end

        autonum = safe_attr(note, :autonum)
        return "Note #{autonum} to entry" if autonum && !autonum.to_s.empty?

        "Note to entry"
      end
    end
  end
end
