# frozen_string_literal: true

module Metanorma
  module Html
    class StandardRenderer < BaseRenderer
        include Renderers::SemanticRenderer
      register_render "Metanorma::Standoc::Document::Root",
                      :render_standard_document
      register_render "Metanorma::Standoc::Document::Terms::Term", :render_term
      register_render "Metanorma::Standoc::Document::Terms::TermSource",
                      :render_term_source
      register_render "Metanorma::Standoc::Document::Terms::FmtDefinitionSemx",
                      :render_fmt_definition_semx
      register_render "Metanorma::Standoc::Document::Sections::TermsSection",
                      :render_terms_section
      register_render "Metanorma::Document::Components::Blocks::RequirementModel",
                      :render_requirement
      register_render "Metanorma::Document::Components::Blocks::RecommendationModel",
                      :render_requirement
      register_render "Metanorma::Document::Components::Blocks::PermissionModel",
                      :render_requirement
      register_render "Metanorma::Document::Components::Blocks::FmtProvision",
                      :render_reqt_component
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
      register_render "Metanorma::Standoc::Document::Sections::Preface",
                      :render_preface
      register_render "Metanorma::Standoc::Document::Sections::Sections",
                      :render_standard_section
      register_render "Metanorma::Standoc::Document::Sections::ContentSection",
                      :render_standard_section
      register_render "Metanorma::Standoc::Document::Sections::DefinitionSection",
                      :render_standard_section
      register_render "Metanorma::Standoc::Document::Sections::FloatingTitle",
                      :render_floating_title
      register_render "Metanorma::Standoc::Document::Blocks::AmendBlock",
                      :render_amend_block
      register_render "Metanorma::Standoc::Document::Sections::Colophon",
                      :render_colophon
      register_render "Metanorma::Standoc::Document::Blocks::ToC",
                      :render_toc

      def render_standard_document(doc, **_opts)
        cover = render_coverpage(doc)
        cover += render_boilerplate(doc) if doc.respond_to?(:boilerplate) &&
          doc.boilerplate

        content_parts = []
        content_parts << (render(doc.preface) || "") if doc.preface
        content_parts << (render_doc_title(doc) || "")
        content_parts << (render(doc.sections) || "") if doc.sections
        doc.annex&.each { |annex| content_parts << (render(annex) || "") }
        content_parts << (render(doc.bibliography) || "") if doc.bibliography
        content_parts << (render(doc.colophon) || "") if doc.respond_to?(:colophon) &&
          doc.colophon

        unless @index_term_collector.empty?
          index_component = Component::IndexSection.new(self)
          content_parts << (index_component.render(@index_term_collector) || "")
        end

        content_parts << (render(doc.indexsect) || "") if doc.indexsect
        content_parts << (render_semantic_annexes(doc) || "")
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
                        "stage_html" => cover_stage_html(bibdata),
                        "tc_html" => cover_tc_html(bibdata),
                        "dates_html" => cover_dates_html(bibdata),
                      })
      end

      def cover_tc_html(bibdata)
        name = cover_tc_name(bibdata)
        return nil unless name

        render_liquid("_element.html.liquid", "tag" => "div",
                                                 "extra_attrs" => %( class="coverpage-tc-name"),
                                                 "content" => %(<span>#{escape_html(name)}</span>))
      end

      # The native covers open with type and maturity bands ("IHO
      # Regulation", "Published 2017-06"); derive both from bibdata.
      # The committee subdivision name renders as the cover tc-name
      # ("hssc"); value-only extraction — the contributor graph is
      # self-referential under to_s/inspect.
      def cover_tc_name(bibdata)
        if bibdata.respond_to?(:subdivision_text_for)
          name = begin
            bibdata.subdivision_text_for("committee", :name)
          rescue StandardError
            nil
          end
          return name if name.is_a?(String) && !name.empty?
        end

        Array(safe_attr(bibdata, :contributor)).each do |c|
          roles = Array(safe_attr(c, :role))
          author = roles.any? { |r| r.is_a?(String) ? r == "author" : safe_attr(r, :type) == "author" }
          next unless author

          org = safe_attr(c, :organization)
          Array(safe_attr(org, :subdivision)).each do |sub|
            name = safe_attr(sub, :name)
            name = cover_date_text(name) unless name.is_a?(String)
            return name if name && !name.empty?
          end
        end
        nil
      end

      def cover_stage_html(bibdata)
        bands = []
        if (doctype = cover_doctype_label(bibdata))
          bands << %(<span class="coverpage-stage" id="#{escape_html(cover_doctype_id(bibdata))}">#{escape_html(doctype)}</span>)
        end
        status = safe_attr(bibdata, :status)
        # status.stage is an Array of mixed-content StageElement;
        # extract the text value (stringifying can hit self-reference).
        stage_el = Array(safe_attr(status, :stage)).first
        stage = if stage_el.nil?
                  nil
                elsif stage_el.is_a?(String)
                  stage_el
                elsif stage_el.respond_to?(:value)
                  Array(stage_el.value).join.strip
                end
        stage = nil if stage.respond_to?(:empty?) && stage.empty?
        if stage
          label = { "in-force" => "Published" }.fetch(stage, stage.capitalize)
          pub = Array(safe_attr(bibdata, :date)).find do |d|
            safe_attr(d, :type) == "published"
          end
          on = pub && (safe_attr(pub, :on) || safe_attr(pub, :from))
          on = cover_date_text(on)
          text = on ? "#{label} #{on}" : label
          bands << %(<p><span class="coverpage-maturity" id="#{escape_html(stage)}">#{escape_html(text)}</span></p>)
        end
        return nil if bands.empty?

        render_liquid("_element.html.liquid", "tag" => "div",
                                                 "extra_attrs" => %( class="coverpage-stage-block"),
                                                 "content" => bands.join)
      end

      def cover_doctype_label(bibdata)
        dt = cover_doctype_value(bibdata)
        return nil unless dt

        pretty = cover_date_text(dt) || dt.to_s
        pretty = pretty.split('-').map(&:capitalize).join(' ')
        prefix = cover_publisher_prefix(bibdata)
        prefix ? "#{prefix} #{pretty}" : pretty
      end

      def cover_doctype_id(bibdata)
        cover_date_text(cover_doctype_value(bibdata))&.downcase
      end

      # doctype lives either on the bibdata or its flavor extension.
      def cover_doctype_value(bibdata)
        Array(safe_attr(bibdata, :doctype)).first ||
          Array(safe_attr(safe_attr(bibdata, :ext), :doctype)).first
      end

      # bibdata dates are Relaton value objects; pull the text out.
      def cover_date_text(v)
        return nil if v.nil?
        return v if v.is_a?(String)
        return Array(v.value).join.strip if v.respond_to?(:value)

        # Relaton DateTime maps <on>YYYY-MM</on> to content.
        return v.content if v.respond_to?(:content) && v.content.is_a?(String)
        return v.text if v.respond_to?(:text) && v.text.is_a?(String)

        nil
      end

      # Publisher abbreviation (preferred) or name from the bibdata
      # contributor graph, value-only extraction: to_s/inspect on lutaml
      # collections recurses into self-referential model graphs.
      def cover_publisher_prefix(bibdata)
        Array(safe_attr(bibdata, :contributor)).each do |c|
          roles = Array(safe_attr(c, :role))
          publisher = roles.any? do |r|
            type = r.is_a?(String) ? r : cover_date_text(safe_attr(r, :type))
            type == "publisher"
          end
          next unless publisher

          org = safe_attr(c, :organization)
          abbr = cover_date_text(safe_attr(org, :abbreviation))
          return abbr if abbr && !abbr.empty?

          name = cover_date_text(safe_attr(org, :name))
          return name if name && !name.empty?
        end
        nil
      end

      # The committee subdivision name renders as the cover tc-name
      # ("hssc"); value-only extraction — the contributor graph is
      # self-referential under to_s/inspect.
      def cover_tc_name(bibdata)
        if bibdata.respond_to?(:subdivision_text_for)
          name = begin
            bibdata.subdivision_text_for("committee", :name)
          rescue StandardError
            nil
          end
          return name if name.is_a?(String) && !name.empty?
        end

        Array(safe_attr(bibdata, :contributor)).each do |c|
          roles = Array(safe_attr(c, :role))
          author = roles.any? { |r| r.is_a?(String) ? r == "author" : safe_attr(r, :type) == "author" }
          next unless author

          org = safe_attr(c, :organization)
          Array(safe_attr(org, :subdivision)).each do |sub|
            name = safe_attr(sub, :name)
            name = cover_date_text(name) unless name.is_a?(String)
            return name if name && !name.empty?
          end
        end
        nil
      end

      def cover_stage_html(bibdata)
        bands = []
        if (doctype = cover_doctype_label(bibdata))
          bands << %(<span class="coverpage-stage" id="#{escape_html(cover_doctype_id(bibdata))}">#{escape_html(doctype)}</span>)
        end
        status = safe_attr(bibdata, :status)
        # status.stage is an Array of mixed-content StageElement;
        # extract the text value (stringifying can hit self-reference).
        stage_el = Array(safe_attr(status, :stage)).first
        stage = if stage_el.nil?
                  nil
                elsif stage_el.is_a?(String)
                  stage_el
                elsif stage_el.respond_to?(:value)
                  Array(stage_el.value).join.strip
                end
        stage = nil if stage.respond_to?(:empty?) && stage.empty?
        if stage
          label = { "in-force" => "Published" }.fetch(stage, stage.capitalize)
          pub = Array(safe_attr(bibdata, :date)).find do |d|
            safe_attr(d, :type) == "published"
          end
          on = pub && (safe_attr(pub, :on) || safe_attr(pub, :from))
          on = cover_date_text(on)
          text = on ? "#{label} #{on}" : label
          bands << %(<p><span class="coverpage-maturity" id="#{escape_html(stage)}">#{escape_html(text)}</span></p>)
        end
        return nil if bands.empty?

        render_liquid("_element.html.liquid", "tag" => "div",
                                                 "extra_attrs" => %( class="coverpage-stage-block"),
                                                 "content" => bands.join)
      end

      def cover_doctype_label(bibdata)
        dt = cover_doctype_value(bibdata)
        return nil unless dt

        pretty = cover_date_text(dt) || dt.to_s
        pretty = pretty.split('-').map(&:capitalize).join(' ')
        prefix = cover_publisher_prefix(bibdata)
        prefix ? "#{prefix} #{pretty}" : pretty
      end

      def cover_doctype_id(bibdata)
        cover_date_text(cover_doctype_value(bibdata))&.downcase
      end

      # doctype lives either on the bibdata or its flavor extension.
      def cover_doctype_value(bibdata)
        Array(safe_attr(bibdata, :doctype)).first ||
          Array(safe_attr(safe_attr(bibdata, :ext), :doctype)).first
      end

      # bibdata dates are Relaton value objects; pull the text out.
      def cover_date_text(v)
        return nil if v.nil?
        return v if v.is_a?(String)
        return Array(v.value).join.strip if v.respond_to?(:value)

        # Relaton DateTime maps <on>YYYY-MM</on> to content.
        return v.content if v.respond_to?(:content) && v.content.is_a?(String)
        return v.text if v.respond_to?(:text) && v.text.is_a?(String)

        nil
      end

      # The contributor graph is self-referential under lutaml-model;
      # walking it for the publisher organization loops forever. The
      # flavor theme already carries the publisher name.
      def cover_publisher_prefix(_bibdata)
        name = theme.respond_to?(:publisher_name) ? theme.publisher_name : nil
        name.is_a?(String) && !name.empty? ? name : nil
      end

      # Document dates (issue/implementation/...) as a cover band.
      def cover_dates_html(bibdata)
        items = Array(safe_attr(bibdata, :date)).filter_map do |d|
          type = cover_date_text(safe_attr(d, :type)) || safe_attr(d, :type)
          on = cover_date_text(safe_attr(d, :on)) || cover_date_text(safe_attr(d, :from))
          next unless type && on

          %(<span class="coverpage-date date-#{escape_html(type)}">#{escape_html(type.capitalize)}: #{escape_html(on)}</span>)
        end
        return nil if items.empty?

        render_liquid("_element.html.liquid", "tag" => "div",
                                                 "extra_attrs" => %( class="coverpage-dates"),
                                                 "content" => items.join)
      end

      # The document <boilerplate> front-matter block (copyright,
      # licence, legal and feedback statements): part of the native
      # cover matter, rendered right after the title cover.
      def render_boilerplate(doc)
        boilerplate = doc.boilerplate
        parts = []
        %i[copyright_statement license_statement legal_statement
           feedback_statement clause paragraphs quote_blocks].each do |grouping|
          Array(boilerplate.public_send(grouping)).each do |child|
            parts << (render(child, level: 1) || "")
          end
        end
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => element_attrs(
                          class: "document-boilerplate",
                        ),
                        "content" => parts.join,
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
        if section.respond_to?(:element_order) && Array(section.element_order).any?
          # Document order (element_order) preserves interleaved blocks —
          # paragraphs between figures, notes between lists — which the
          # attribute-grouping path below cannot express.
          parts << (render_ordered_content(section, level) || "")
        else
          parts << (render_standard_section_blocks(section, level) || "")
          parts << (render_subsections(section, level) || "") if with_subsections
          if with_terms
            section.terms&.each { |term| parts << (render_term(term, level: level + 1) || "") }
          end
          parts << (render_section_groupings(section, level,
                                             skip_terms: with_terms) || "")
        end
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => attrs,
                        "content" => parts.join,
                      })
      end

      # Clause-embedded terms/definitions/references groupings are not
      # `clause` children, so render_subsections skips them and their
      # content would be lost. Render each grouping's children through
      # the normal dispatch (DefinitionSection, ReferenceSection, Term).
      def render_section_groupings(section, level, skip_terms: false)
        parts = []
        %i[terms definitions references].each do |grouping|
          next if skip_terms && grouping == :terms

          Array(safe_attr(section, grouping)).each do |child|
            parts << (render(child, level: level + 1) || "")
          end
        end
        parts.join
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

      # Requirement / recommendation / permission blocks: the requirements
      # table — label row, then one row per populated component
      # (subject, statement, specification, etc.). Component children
      # (p/ol/ul/...) render through the regular dispatch.
      REQ_COMPONENTS = {
        description: "Description",
        specification: "Statement",
        measurement_target: "Measurement target",
        verification: "Verification",
        inherit: "Inheritance",
        import: "Imported",
      }.freeze

      def render_requirement(req, **_opts)
        parts = []
        label = req.respond_to?(:fmt_name) && req.fmt_name ? render(req.fmt_name) : reqt_label(req)
        parts << %(<div class="reqt"><p class="reqt-label">#{escape_html(label.to_s)}</p>)

        # Presentation-layer formatted provision: the requirement's own
        # rendered table — when present it carries the full content.
        if req.respond_to?(:fmt_provision) && req.fmt_provision
          parts << (render(req.fmt_provision) || "")

          # Nested requirements (tests inside conformance classes) are
          # not part of the formatted table — render them after it.
          %i[requirement recommendation permission].each do |attr|
            next unless req.respond_to?(attr)
            Array(req.send(attr)).each { |nested| parts << (render(nested) || "") }
          end

          parts << %(</div>)
          return parts.join
        end

        REQ_COMPONENTS.each do |attr, row_label|
          value = req.respond_to?(attr) ? req.send(attr) : nil
          next if value.nil? || (value.respond_to?(:empty?) && value.empty?)

          cells = Array(value).filter_map { |component| render_reqt_component(component) }.join
          next if cells.empty?

          parts << %(<div class="reqt-row"><span class="reqt-key">#{row_label}:</span> #{cells}</div>)
        end

        if req.respond_to?(:classification) && req.classification&.any?
          cls = req.classification.filter_map do |c|
            next unless c.respond_to?(:value)
            "#{c.respond_to?(:tag) ? c.tag : ''} #{c.value}".strip
          end.reject(&:empty?).join("; ")
          parts << %(<div class="reqt-row"><span class="reqt-key">Classification:</span> #{escape_html(cls)}</div>) unless cls.empty?
        end

        parts << %(</div>)
        parts.join
      end

      # Requirement labels come from mn-requirements' i18n vocabulary
      # (the same strings the native isodoc pipeline renders), selected
      # by the requirement's type attribute.
      def reqt_labels
        @reqt_labels ||= begin
          require "isodoc-i18n"
          gem_path = Gem.loaded_specs["mn-requirements"]&.full_gem_path
            gem_path && require(File.join(gem_path, "lib/isodoc/i18n"))
          i18n = IsoDoc::MnRequirementsI18n.new(document_language, nil)
          req = Hash(i18n.get["requirements"])
          # vocabulary nests under default: and modspec: — merge them
          Hash(req["default"]).merge(Hash(req["modspec"]))
        rescue StandardError
          {}
        end
      end

      def document_language
        lang = respond_to?(:language) ? language : nil
        lang.to_s.empty? ? "en" : lang.to_s
      rescue StandardError
        "en"
      end

      def reqt_label(req)
        type = req.respond_to?(:type) ? req.type.to_s : ""
        base = reqt_labels[type] ||
               reqt_labels[req.class.name.split("::").last.to_s.delete_suffix("Model").downcase] ||
               req.class.name.split("::").last.to_s.delete_suffix("Model").capitalize
        ident = req.identifier.to_s if req.respond_to?(:identifier)
        ident&.empty? ? base : "#{base} #{ident}"
      end

      def render_reqt_component(component, **_opts)
        return "" if component.nil? || component.is_a?(String)

        component.class.attributes.each_key.filter_map do |attr|
          value = component.send(attr) rescue next
          if value.is_a?(Array)
            value.map { |v| v.is_a?(String) ? v : render(v) }.join
          elsif !value.nil? && !value.is_a?(String)
            render(value)
          end
        end.join
      end

      # fmt-xref-label: the cross-reference label text ("Requirement
      # A.14-1", "Clause 3") carried ahead of blocks in mixed content.
      def render_fmt_xref_label(el, **_opts)
        parts = []
        parts << Array(el.text).join if el.respond_to?(:text) && el.text
        Array(el.semx).each { |s| parts << render(s) } if el.respond_to?(:semx)
        Array(el.span).each { |s| parts << render(s) } if el.respond_to?(:span)
        joined = parts.join
        joined.empty? ? "" : %(<span class="fmt-xref-label">#{joined}</span>)
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

      # Amend block (machine-readable change): the description paragraphs
      # render bare, the new content blocks render inside a single
      # Quote AmendNewcontent wrapper — matching native isodoc output.
      def render_amend_block(amend, **opts)
        parts = []
        Array(safe_attr(amend, :description)).each do |desc|
          parts << render_amend_content(desc, **opts)
        end
        new_contents = Array(safe_attr(amend, :new_content))
        if new_contents.any?
          inner = new_contents.map { |nc| render_amend_content(nc, **opts) }.join
          attrs = element_attrs(id: safe_attr(amend, :id),
                                class: "Quote AmendNewcontent")
          parts << render_liquid("_element.html.liquid", {
                                   "tag" => "div",
                                   "extra_attrs" => attrs,
                                   "content" => inner,
                                 })
        end
        parts.join
      end

      def render_amend_content(content, **opts)
        parts = []
        %i[paragraphs note ol ul dl figure clause].each do |attr|
          Array(safe_attr(content, attr)).each do |child|
            parts << (render_amend_child(child, **opts) || "")
          end
        end
        parts.join
      end

      def render_amend_child(child, **opts)
        if child.is_a?(Metanorma::Standoc::Document::Sections::ClauseSection)
          render_amend_clause(child, **opts)
        else
          render(child, **opts)
        end
      end

      # An annex introduced by an amendment carries its identity in
      # number/obligation attributes rather than a formatted title:
      # native isodoc renders the Annex label, the obligation and the
      # title as one heading paragraph.
      def render_amend_clause(clause, level: 1, **opts)
        return render(clause, level: level, **opts) unless safe_attr(clause, :type) == "annex"

        heading = +""
        number = safe_attr(clause, :number)
        heading << "<b>Annex #{escape_html(number)}</b><br />" if number
        obligation = safe_attr(clause, :obligation)
        if obligation
          heading << %(<span class="obligation">(#{escape_html(obligation)})</span><br />)
        end
        title = safe_attr(clause, :fmt_title) || safe_attr(clause, :title)
        heading << render_mixed_inline(title).to_s if title

        body = Array(clause.blocks).filter_map do |node|
          next if is_title_element?(node, clause)

          render(node, level: level + 1)
        end.join
        attrs = element_attrs(id: safe_attr(clause, :id))
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => attrs,
                        "content" => %(<p class="h1">#{heading}</p>#{body}),
                      })
      end

      # Authored table-of-contents blocks (clause type="toc"): a list of
      # cross-references rendered as a toc div, mirroring the native
      # isodoc layout.
      def render_toc(toc, **_opts)
        list = safe_attr(toc, :list)
        content = Array(list).filter_map do |ul|
          render_unordered_list(ul)
        end.join
        render_liquid("_element.html.liquid", {
                        "tag" => "div",
                        "extra_attrs" => element_attrs(class: "toc"),
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
        # IEEE-style metadata definition list (figdl), rendered before the
        # definition like the native term entry.
        Array(safe_attr(term, :dl)).each do |list|
          parts << (render_definition_list(list) || "")
        end
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

      # The <semx> wrapper inside <fmt-definition> carries the definition's
      # block content one level down (standoc FmtDefinitionSemx); render
      # its children in document order.
      def render_fmt_definition_semx(semx, **_opts)
        parts = []
        walk_ordered(semx) do |type, obj|
          next unless type == :element

          parts << case obj
                   when Metanorma::Document::Components::Paragraphs::ParagraphBlock
                     render_paragraph(obj)
                   when Metanorma::Standoc::Document::Terms::TermNote
                     render_term_note(obj)
                   when Metanorma::Document::Components::Lists::DefinitionList
                     render_definition_list(obj)
                   when Metanorma::Document::Components::Lists::OrderedList
                     render_ordered_list(obj)
                   when Metanorma::Document::Components::Lists::UnorderedList
                     render_unordered_list(obj)
                   end
        end
        parts.compact.join
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
          # When the fmt-definition flow already carries the source inline
          # (IEEE-style "(adapted from …)" inside the definition), the
          # semantic [SOURCE: …] line would be a duplicate the native
          # titlepage never emits.
          unless fmt_definition_carries_source?(term)
            term.source&.each { |src| parts << (render_term_source(src) || "") }
            safe_attr(term, :termsource)&.each do |source|
              parts << (render_term_source_element(source) || "")
            end
          end
        end
        parts.join
      end

      SEMX_SOURCE_SEARCH_ATTRS = %i[semx p span strong em sup sub xref eref
                                    origin fmt_xref fmt_eref fmt_origin].freeze

      def fmt_definition_carries_source?(term)
        fmt_def = safe_attr(term, :fmt_definition)
        return false unless fmt_def

        candidates = Array(fmt_def.semx)
        candidates << fmt_def if fmt_def.is_a?(Lutaml::Model::Serializable) &&
                                 !fmt_def.is_a?(Metanorma::Document::Components::Inline::SemxElement)
        candidates.any? { |n| semx_tree_has_source?(n) }
      end

      def semx_tree_has_source?(node, seen = nil)
        return false unless node.is_a?(Lutaml::Model::Serializable)

        # semx trees may be self-referential (fmt wrappers pointing back
        # at their own definition); guard the walk with an identity set.
        seen ||= {}.compare_by_identity
        return false if seen[node]

        seen[node] = true
        return true if node.is_a?(Metanorma::Document::Components::Inline::SemxElement) &&
                       node.element_attr.to_s == "source"

        SEMX_SOURCE_SEARCH_ATTRS.each do |attr|
          next unless node.respond_to?(attr)

          Array(node.public_send(attr)).each do |child|
            return true if semx_tree_has_source?(child, seen)
          end
        end
        false
      end

      def extract_term_name(term)
        fmt_pref = safe_attr(term, :fmt_preferred)
        if fmt_pref.is_a?(String) && !fmt_pref.empty?
          return fmt_pref
        end
        if fmt_pref.is_a?(Array) && !fmt_pref.empty?
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
        name_element = designation_name_element(designation)
        return nil unless name_element

        inner = Array(name_element).map do |n|
          n.is_a?(String) ? escape_html(n) : render_mixed_inline(n)
        end.join
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

      # The raw name element(s) of a designation — String or
      # mixed-content name elements (e.g. TermNameElement) — for rich
      # inline rendering by the caller.
      def designation_name_element(designation)
        if designation.is_a?(Metanorma::Standoc::Document::Terms::Designation) && designation.expression
          expr = designation.expression
          if expr.is_a?(Metanorma::Standoc::Document::Terms::TermExpression) && expr.name
            expr.name
          end
        elsif designation.is_a?(Metanorma::Standoc::Document::Terms::TermExpression)
          designation.name
        elsif designation.is_a?(Metanorma::Standoc::Document::Terms::Designation)
          designation
        end
      end

      def extract_designation_name(designation)
        if designation.is_a?(Metanorma::Standoc::Document::Terms::Designation) && designation.expression
          expr = designation.expression
          if expr.is_a?(Metanorma::Standoc::Document::Terms::TermExpression) && expr.name
            join_designation_names(expr.name)
          end
        elsif designation.is_a?(Metanorma::Standoc::Document::Terms::TermExpression) && designation.name
          join_designation_names(designation.name)
        else
          extract_text_value(designation)
        end
      end

      # Designation names may be plain strings or mixed-content name
      # elements (e.g. TermNameElement); stringify through the text
      # extractors instead of Object#to_s.
      def join_designation_names(names)
        Array(names).map do |n|
          next n if n.is_a?(String)

          extract_plain_text(n) || extract_text_value(n) || ""
        end.join
      end

      def render_term_definition(definition)
        return nil unless definition
        return nil unless definition.is_a?(Metanorma::Standoc::Document::Terms::TermDefinition)

        ve = definition.verbalexpression
        unless ve
          # Legacy presentation XML states the definition's blocks
          # directly under <definition>: render them in document order.
          legacy = collect_ordered_children(definition)
          return legacy.empty? ? nil : legacy.filter_map { |child| render(child) }.join
        end

        walked = collect_ordered_children(ve)
        unless walked.empty?
          return walked.filter_map { |child| render(child) }.join
        end

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

      def render_term_source(source, **_opts)
        return nil unless source

        parts = []
        termsource = safe_attr(source, :termsource)
        origin = safe_attr(source, :origin)

        if termsource
          parts << (render_mixed_inline(termsource) || "")
        elsif origin
          citeas = safe_attr(origin, :citeas)
          bibitemid = safe_attr(origin, :bibitemid)

          # isodoc shows the origin's own text when the source states it
          # (<origin citeas="ISO 19101">ISO 19101-1:2014</origin>),
          # falling back to the citeas anchor.
          display = Array(safe_attr(origin, :content)).join.strip
          display = citeas.to_s if display.empty? && citeas && !citeas.to_s.empty?
          parts << if !display.empty? && bibitemid && !bibitemid.to_s.empty?
                     render_liquid("_link.html.liquid", {
                                     "attrs" => element_attrs(
                                       href: "##{escape_html(bibitemid.to_s)}", class: "bibref",
                                     ),
                                     "content" => escape_html(display),
                                   })
                   elsif !display.empty?
                     escape_html(display)
                   else
                     render_mixed_inline(origin) || ""
                   end

          modification = safe_attr(source, :modification)
          if modification
            mod_content = Array(safe_attr(modification, :p)).map do |para|
              render_mixed_inline(para) || ""
            end.join
            parts << ", modified — #{mod_content}" unless mod_content.strip.empty?
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

      # The document <colophon> (e.g. the BIPM "Document Control" and
      # "Revision History" clauses): trailing display clauses rendered
      # like any other clause content.
      def render_colophon(colophon, **_opts)
        parts = Array(colophon.clause).filter_map do |clause|
          render(clause)
        end
        parts.join
      end

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
        Array(safe_attr(section, :ol)).each do |list|
          parts << (render_ordered_list(list) || "")
        end
        Array(safe_attr(section, :ul)).each do |list|
          parts << (render_unordered_list(list) || "")
        end
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
        if (fr = item.formatted_ref)
          frs = fr.is_a?(Array) ? fr : [fr]
          frs.each do |f|
            parts << (render_mixed_inline(f) || "")
          end
          return parts.join
        end

        parts << (bibitem_author_prefix(item) || "")

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

        parts << (bibitem_publisher_statement(item) || "")
        parts << (bibitem_uri_statement(item) || "")
        parts.join
      end

      # isodoc reference layout: authors lead the entry ("A. Phillips,
      # M. Davis: ") ahead of the document identifier. Author entities
      # are persons (completename) or organizations (name).
      def bibitem_author_prefix(item)
        names = Array(item.contributor).filter_map do |contributor|
          next unless Array(contributor.role).any? { |r| safe_attr(r, :type) == "author" }

          if contributor.person
            Array(contributor.person.name&.completename).map do |name|
              extract_text_value(name).to_s
            end.join
          elsif contributor.organization
            Array(contributor.organization.name).map do |name|
              extract_text_value(name).to_s
            end.join(", ")
          end
        end.map(&:strip).reject(&:empty?)
        return nil if names.empty?

        render_liquid("_inline_span.html.liquid", {
                        "attrs" => " class=\"ref-authors\"",
                        "content" => "#{escape_html(names.join(', '))}: ",
                      })
      end

      # Publisher, place and publication year close the entry
      # ("Open Geospatial Consortium , Geneva (2004).").
      def bibitem_publisher_statement(item)
        publishers = Array(item.contributor).filter_map do |contributor|
          next unless Array(contributor.role).any? { |r| safe_attr(r, :type) == "publisher" }
          next unless contributor.organization

          Array(contributor.organization.name).map do |name|
            extract_text_value(name).to_s
          end.join(", ").strip
        end.reject(&:empty?)

        places = Array(item.place).map do |place|
          extract_text_value(place).to_s
        end.map(&:strip).reject(&:empty?)

        segments = publishers + places
        return nil if segments.empty?

        year = Array(item.date).filter_map do |date|
          next unless safe_attr(date, :type) == "published"

          date_on = date.is_a?(Metanorma::Document::Relaton::BibliographicDate) ? date.on : nil
          value = extract_text_value(date_on || safe_attr(date, :text)).to_s
          value[/\d{4}/]
        end.first

        closing = year ? " (#{escape_html(year)})." : "."
        render_liquid("_inline_span.html.liquid", {
                        "attrs" => " class=\"ref-publisher\"",
                        "content" => "#{escape_html(segments.join(', '))}#{closing} ",
                      })
      end

      # The reference's canonical URI is visible text in isodoc output,
      # not only an href on the identifier anchor.
      def bibitem_uri_statement(item)
        url = bibitem_url(item)
        return nil unless url

        render_liquid("_inline_span.html.liquid", {
                        "attrs" => " class=\"ref-uri\"",
                        "content" => escape_html(url),
                      })
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
           quote_blocks requirement recommendation permission
           term_sources].each do |attr|
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

      # Semantic notes (e.g. inside amendment newcontent) carry their
      # number as the number attribute, with no fmt-name or autonum.
      def extract_block_label(block, default)
        label = super
        return label unless label == default

        number = safe_attr(block, :number)
        if number && !number.to_s.empty?
          "#{default} #{number}"
        else
          label
        end
      end
    end
  end
end
