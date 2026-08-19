# frozen_string_literal: true

module Metanorma
  module Html
    class StandardRenderer < BaseRenderer
      register_render "Metanorma::Standoc::Document::Root",
                      :render_standard_document
      register_render "Metanorma::Standoc::Document::Terms::Term", :render_term
      register_render "Metanorma::Standoc::Document::Sections::TermsSection",
                      :render_terms_section
      register_render "Metanorma::Standoc::Document::Sections::StandardReferencesSection",
                      :render_references_section
      register_render "Metanorma::Standoc::Document::Sections::BibliographySection",
                      :render_bibliography
      register_render "Metanorma::Standoc::Document::Sections::ClauseSection",
                      :render_clause_section
      register_render "Metanorma::Standoc::Document::Sections::AnnexSection",
                      :render_annex_section
      register_render "Metanorma::Standoc::Document::Sections::StandardSection",
                      :render_standard_section
      register_render "Metanorma::Standoc::Document::Sections::Abstract",
                      :render_abstract_section
      register_render "Metanorma::Standoc::Document::Sections::Foreword",
                      :render_foreword_section
      register_render "Metanorma::Standoc::Document::Sections::Introduction",
                      :render_introduction_section
      register_render "Metanorma::Standoc::Document::Sections::FloatingTitle",
                      :render_floating_title
      register_render "Metanorma::Standoc::Document::Blocks::AmendBlock",
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

        cover_id = extract_primary_doc_id

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
          section.terms&.each { |term| parts << (render_term(term, level: level + 1) || "") }
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

      # Unified term entry renderer. Handles both semantic-only term models
      # (StandardDocument::Terms::Term) and presentation-aware models with
      # fmt-* attributes (IsoDocument::Terms::IsoTerm): safe_attr returns nil
      # for attributes a model does not declare, so the fmt-* branches are
      # skipped automatically on semantic-only models. +level+ is the term's
      # TermNum heading level (section level + 1, per isodoc's term_header).
      def render_term(term, level: 2, **_opts)
        attrs = element_attrs(id: safe_attr(term, :id), **term_data_attrs(term))
        fmt_definition = safe_attr(term, :fmt_definition)

        parts = []
        parts << (render_term_number(term, level: level) || "")
        parts << render_term_designations(term, :fmt_preferred, :preferred,
                                          "preferred")
        parts << render_term_designations(term, :fmt_admitted, :admitted,
                                          "admitted")
        parts << render_term_designations(term, :fmt_deprecates, :deprecates,
                                          "deprecated")
        parts << (render_term_domain(term, fmt_definition) || "")
        parts << render_term_definitions(term, fmt_definition)
        parts << render_term_note_parts(term)
        parts << render_term_example_parts(term)
        parts << render_term_source_parts(term)
        safe_attr(term, :admonition)&.each do |admonition|
          parts << (render_admonition(admonition) || "")
        end
        safe_attr(term, :term)&.each { |sub| parts << (render_term(sub, level: level + 1) || "") }
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => attrs,
                        "content" => parts.join,
                      })
      end

      def term_data_attrs(term)
        term_name = extract_term_name(term)
        term_definition = extract_term_definition(term)
        data_attrs = {}
        if term_name && !term_name.empty?
          data_attrs["data-term-name"] = term_name
        end
        if term_definition && !term_definition.empty?
          data_attrs["data-term-definition"] = term_definition
        end
        data_attrs
      end

      # The term number renders as a TermNum HEADING one level below the
      # enclosing section heading (isodoc term_header postprocess: p.TermNum
      # becomes h(parent+1), so top-level terms get h2, nested terms h3+).
      def render_term_number(term, level: 2)
        fmt_name = safe_attr(term, :fmt_name)
        term_number = safe_attr(term, :term_number)
        if fmt_name
          render_liquid("_term_number.html.liquid", {
                          "level" => [level, 6].min,
                          "content" => render_inline_element(fmt_name),
                        })
        elsif term_number
          number_text = if term_number.is_a?(String)
                          term_number
                        else
                          extract_text_value(term_number)
                        end
          render_liquid("_term_number.html.liquid", {
                          "level" => [level, 6].min,
                          "content" => escape_html(number_text),
                        })
        end
      end

      # Designations (preferred/admitted/deprecated): fmt-* presentation
      # elements win when present; otherwise render semantic designations.
      def render_term_designations(term, fmt_attr, semantic_attr, type)
        fmt = safe_attr(term, fmt_attr)
        fmt_list = fmt.is_a?(Array) ? fmt : [fmt].compact
        parts = []
        if fmt_list.empty?
          term.public_send(semantic_attr)&.each do |designation|
            parts << (render_term_designation(designation, type) || "")
          end
        else
          fmt_list.each do |element|
            element.p&.each { |para| parts << (render_paragraph(para) || "") }
          end
        end
        parts.join
      end

      def render_term_domain(term, fmt_definition)
        return nil if fmt_definition

        domain = term.domain
        return nil unless domain

        domain_text = domain.is_a?(String) ? domain : safe_attr(domain, :text).to_s
        return nil if domain_text.empty?

        render_liquid("_term_domain.html.liquid", {
                        "text" => escape_html(domain_text),
                      }).to_s
      end

      def render_term_definitions(term, fmt_definition)
        return render_ordered_content(fmt_definition) || "" if fmt_definition

        parts = []
        safe_attr(term, :p)&.each do |para|
          parts << (render_paragraph(para) || "")
        end
        term.definition&.each do |definition|
          parts << (render_term_definition(definition) || "")
        end
        parts.join
      end

      def render_term_note_parts(term)
        notes = safe_attr(term, :termnote) || Array(safe_attr(term, :note))
        parts = []
        notes.each_with_index do |note, i|
          parts << (render_term_note_item(note, i) || "")
        end
        parts.join
      end

      # A term note can be a raw String (rendered with a "Note N to entry"
      # label), a termnote element (labelled wrapper), or a plain block
      # (rendered as a generic note).
      def render_term_note_item(note, index)
        if note.is_a?(String)
          render_liquid("_term_text_note.html.liquid", {
                          "label" => "Note #{index + 1} to entry: ",
                          "content" => escape_html(note),
                        }).to_s
        elsif term_scoped_block?(note)
          render_term_note(note)
        else
          render_note(note)
        end
      end

      def render_term_example_parts(term)
        examples = safe_attr(term, :termexample) ||
          Array(safe_attr(term, :example))
        examples.map do |example|
          render_term_example_item(example) || ""
        end.join
      end

      # A term example can be a termexample element (labelled wrapper), a
      # raw String, or a plain paragraph block (both rendered as paragraphs).
      # render_paragraph cannot take a bare String (render_mixed_inline
      # expects a model), so Strings go through the paragraph template
      # directly — same markup render_paragraph would emit.
      def render_term_example_item(example)
        if example.is_a?(String)
          return render_liquid("_paragraph.html.liquid", {
                                 "attrs" => "",
                                 "content" => escape_html(example),
                               })
        end
        return render_term_example(example) if term_scoped_block?(example)

        render_paragraph(example)
      end

      # Termnote/termexample elements wrap block children (`p`, lists);
      # plain paragraph blocks and Strings do not declare a `p` attribute.
      def term_scoped_block?(node)
        node.is_a?(Lutaml::Model::Serializable) &&
          node.class.attributes.key?(:p)
      end

      def render_term_source_parts(term)
        fmt_termsource = safe_attr(term, :fmt_termsource)
        parts = []
        if fmt_termsource && !fmt_termsource.empty?
          fmt_termsource.each do |source|
            parts << render_liquid("_paragraph.html.liquid", {
                                     "attrs" => " class=\"term-source\"",
                                     "content" => render_mixed_inline(source),
                                   })
          end
        else
          term.source&.each { |src| parts << (render_term_source(src) || "") }
          safe_attr(term, :termsource)&.each do |source|
            parts << (render_term_source_element(source) || "")
          end
        end
        parts.join
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

      PREFERRED_LINK_TYPES = %w[src citation].freeze

      def bibitem_url(item)
        links = Array(item.link)
        return nil if links.empty?

        preferred = links.find { |l| PREFERRED_LINK_TYPES.include?(l.type) }
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
          val.match?(/\A\[?\d+\]?\z/) ? false : !val.match?(/\A(?:URN|[a-z]+-reference)\s/)
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
          val.match?(/\A\[?\d+\]?\z/) ? false : !val.match?(/\A(?:URN|[a-z]+-reference)\s/)
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
