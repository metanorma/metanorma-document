# frozen_string_literal: true

module Metanorma
  module Html
    # Renders BasicDocument components to HTML.
    # Subclassed by StandardRenderer and flavor-specific renderers.
    class BaseRenderer
      def initialize
        @output = +""
        @toc_entries = []
      end

      def to_html
        @output
      end

      def toc_entries
        @toc_entries
      end

      def register_toc_entry(id:, level:, text:)
        @toc_entries << { id: id, level: level, text: text }
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
              parts << "  "
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
        if parts.join.strip.empty? && node.respond_to?(:text)
          t = node.text
          parts << (t.is_a?(Array) ? t.join : t.to_s)
        end

        parts.join.strip
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
        attrs = element_attrs(id: safe_attr(table, :id), class: "tableblock")
        tag("table", attrs) do
          # Table name/caption — use fmt_name (presentation) or name (semantic)
          # This contains the display text like "Table 1 — Some Title"
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
          render_table_section(table.tfoot, "tfoot") if table.tfoot
          table.note&.each { |n| render_note(n) }
          table.dl&.then { |dl| render_definition_list(dl) }
        end
      end

      def render_table_colgroup(colgroup)
        colgroup.col&.each do |col|
          attrs = element_attrs(style: col.width ? "width: #{col.width}" : nil)
          @output << "<col#{attrs}>"
        end
      end

      def render_table_section(section, tag_name)
        @output << "<#{tag_name}>"
        section.tr&.each do |tr|
          @output << "<tr>"
          # Render th cells (header cells)
          Array(tr.th).each do |th|
            attrs = element_attrs(
              colspan: safe_attr(th, :colspan),
              rowspan: safe_attr(th, :rowspan),
              align: safe_attr(th, :alignment),
              valign: safe_attr(th, :vertical_alignment),
            )
            @output << "<th#{attrs}>"
            render_mixed_inline(th)
            @output << "</th>"
          end
          # Render td cells (data cells)
          Array(tr.td).each do |td|
            attrs = element_attrs(
              colspan: safe_attr(td, :colspan),
              rowspan: safe_attr(td, :rowspan),
              align: safe_attr(td, :alignment),
              valign: safe_attr(td, :vertical_alignment),
            )
            @output << "<td#{attrs}>"
            render_mixed_inline(td)
            @output << "</td>"
          end
          @output << "</tr>"
        end
        @output << "</#{tag_name}>"
      end

      def render_unordered_list(ul, **_opts)
        attrs = element_attrs(id: safe_attr(ul, :id), class: safe_attr(ul, :class_attr))
        tag("ul", attrs) do
          ul.listitem&.each { |li| render_list_item(li) }
        end
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
            render(child)
          end
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
        attrs = element_attrs(id: safe_attr(note, :id), class: "Note")
        tag("div", attrs) do
          label = extract_block_label(note, "NOTE")
          @output << %(<span class="note_label">#{escape_html(label)}</span>&nbsp;)
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
          @output << %(<span class="example_label">#{escape_html(label)}</span>&nbsp;)
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
            @output << "<p class=\"sourcecode-name\">"
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
          @output << escape_html(code_text)
          @output << "</code></pre>"
        end
      end

      def render_formula(formula, **_opts)
        attrs = element_attrs(id: safe_attr(formula, :id), class: "formula")
        tag("div", attrs) do
          if formula.stem
            @output << render_stem_content(formula.stem)
          end
          formula.dl&.then { |dl| render_definition_list(dl) }
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

      def render_mixed_inline(node)
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

      # Iterate element_order directly, preserving whitespace text nodes
      # that each_mixed_content drops (it skips text where text.strip.empty?)
      def render_ordered_inline(node)
        xml_mapping = node.class.mappings_for(:xml, node.lutaml_register)
        unless xml_mapping
          node.each_mixed_content do |child|
            case child
            when String
              @output << escape_html(child)
            else
              render_inline_element(child)
            end
          end
          return
        end

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
            @output << escape_html(el.text_content) if el.text_content
          elsif el.element?
            # Handle <tab/> elements that aren't mapped to attributes
            if el.name == "tab"
              @output << "\u00a0\u00a0"
              next
            end

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
            render_inline_element(obj) if obj
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
          render_inline_tag("span", element, class: "smallcap")
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
          render_xref(element)
        when Metanorma::Document::Components::Inline::ErefElement
          render_eref(element)
        when Metanorma::Document::Components::Inline::SpanElement
          attrs = element_attrs(style: safe_attr(element, :style), class: safe_attr(element, :class_attr))
          tag("span", attrs) { render_mixed_inline(element) }
        when Metanorma::Document::Components::Inline::FnElement
          render_fn(element)
        when Metanorma::Document::Components::Inline::ConceptElement
          render_concept(element)
        when Metanorma::Document::Components::Inline::StemInlineElement
          @output << render_stem_content(element)
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
             Metanorma::Document::Components::Inline::FmtXrefElement,
             Metanorma::Document::Components::Inline::FmtSourcecodeElement
          render_mixed_inline(element)
        when Metanorma::Document::Components::Inline::FmtStemElement
          @output << render_stem_content(element)
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
        when Metanorma::Document::Components::Blocks::NoteBlock
          render_note(element)
        else
          # Attempt generic mixed content rendering for unknown inline types
          if element.respond_to?(:each_mixed_content)
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
          next unless node.respond_to?(attr)

          values = node.send(attr)
          next if values.nil?

          Array(values).each { |v| render_inline_element(v) }
        end
      end

      # Render SemxElement display content only, skipping semantic linkage.
      # semx wraps both semantic data (origin, xref, source, etc.) and
      # display content (fmt-xref, span, strong, etc.). Only render display.
      def render_semx_content(element)
        # Display-only attribute names in SemxElement
        display_attrs = %i[text fmt_xref fmt_link span strong em sup p semx
                           asciimath math sub_child tt_child br_child tab_child
                           stem_child figure_child formula_child sourcecode_child]

        # If element_order is available, use it to preserve order
        if element.element_order && !element.element_order.empty?
          xml_mapping = element.class.mappings_for(:xml, element.lutaml_register)
          if xml_mapping
            element_to_attr = {}
            xml_mapping.mapping_elements_hash.each_value do |rule_or_array|
              Array(rule_or_array).each do |rule|
                element_to_attr[rule.name] = rule.to
                element_to_attr[rule.name.to_s] = rule.to if rule.name.is_a?(Symbol)
              end
            end

            indices = Hash.new(0)
            element.element_order.each do |el|
              if el.text?
                @output << escape_html(el.text_content) if el.text_content
              elsif el.element?
                attr_name = element_to_attr[el.name]
                next unless attr_name
                next unless display_attrs.include?(attr_name)

                coll = element.send(attr_name)
                obj = if coll.is_a?(Array)
                        idx = indices[attr_name]
                        indices[attr_name] += 1
                        coll[idx]
                      else
                        coll
                      end
                render_inline_element(obj) if obj
              end
            end
            return
          end
        end

        # Fallback: render display attributes sequentially
        display_attrs.each do |attr|
          next unless element.class.method_defined?(attr)
          val = element.send(attr)
          next if val.nil?
          if val.is_a?(Array)
            val.each { |v| render_inline_element(v) }
          elsif val.is_a?(String)
            @output << escape_html(val)
          else
            render_inline_element(val)
          end
        end
      end

      def render_inline_tag(tag_name, element, **extra_attrs)
        tag(tag_name, element_attrs(**extra_attrs)) { render_mixed_inline(element) }
      end

      def render_link(link)
        target = safe_attr(link, :target) || safe_attr(link, :href)
        attrs = element_attrs(href: target, id: safe_attr(link, :id), class: safe_attr(link, :class_attr))
        tag("a", attrs) do
          content = safe_attr(link, :content)
          if content && !Array(content).join.strip.empty?
            render_mixed_inline(link)
          else
            @output << escape_html(target.to_s)
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
        attrs = element_attrs(id: safe_attr(fn, :id), class: "footnote")
        tag("span", attrs) do
          label = safe_attr(fn, :fn_label) || safe_attr(fn, :reference)
          @output << "<sup>#{escape_html(label.to_s)}</sup>" if label
        end
      end

      def render_concept(concept)
        render_mixed_inline(concept)
      end

      # --- Stem/math rendering ---

      def render_stem_content(stem)
        return "" if stem.nil?

        if stem.respond_to?(:math) && stem.math
          math_items = Array(stem.math)
          if math_items.first.is_a?(Metanorma::Document::Components::Inline::MathElement)
            math_items.map { |m| m.content.to_s }.join
          elsif math_items.first.respond_to?(:to_xml)
            math_items.map(&:to_xml).join
          else
            escape_html(math_items.map(&:to_s).join)
          end
        elsif stem.respond_to?(:asciimath) && stem.asciimath
          am = stem.asciimath
          text = am.respond_to?(:text) ? Array(am.text).join : am.to_s
          %(<span class="stem">#{escape_html(text)}</span>)
        elsif stem.respond_to?(:latexmath) && stem.latexmath
          lm = stem.latexmath
          text = lm.respond_to?(:text) ? Array(lm.text).join : lm.to_s
          %(<span class="stem">#{escape_html(text)}</span>)
        elsif stem.respond_to?(:text) && stem.text
          text = Array(stem.text).join
          %(<span class="stem">#{escape_html(text)}</span>)
        else
          ""
        end
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
          next if v.nil? || v == false || (v.respond_to?(:empty?) && v.empty?)

          parts << %( #{k}="#{escape_html(v.to_s)}")
        end
        parts.join
      end

      def safe_attr(obj, method_name)
        obj.public_send(method_name)
      rescue NoMethodError
        nil
      end

      # Extract the display label for a block (note, example, etc.)
      # Priority: <name> element text > autonum attribute > default fallback
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
        if title.respond_to?(:content)
          title.content.to_s
        elsif title.respond_to?(:text)
          Array(title.text).join
        elsif title.is_a?(String)
          title
        else
          title.to_s
        end
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

      # Extract a plain text string from a value that may be a model object, array, or string.
      def extract_text_value(val)
        return nil if val.nil?
        return val if val.is_a?(String)

        if val.is_a?(Array)
          val.map { |v| extract_text_value(v) }.join
        elsif val.respond_to?(:content)
          c = val.content
          c = nil if c.equal?(val) # avoid self-referential
          c ? extract_text_value(c) : nil
        elsif val.respond_to?(:text)
          t = val.text
          t ? extract_text_value(t) : nil
        elsif val.respond_to?(:value)
          v = val.value
          v ? extract_text_value(v) : nil
        elsif val.respond_to?(:id) && val.id.is_a?(String)
          val.id
        else
          val.to_s
        end
      end
    end
  end
end
