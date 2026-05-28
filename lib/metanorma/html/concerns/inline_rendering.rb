# frozen_string_literal: true

module Metanorma
  module Html
    module InlineRendering
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

          coll = node.public_send(attr_name)
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
        elsif next_el&.element? && next_el.name == next_tag
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
      # Models using map_all_content: raw XML in content
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
      node.is_a?(Lutaml::Model::Serializable) &&
        node.content.is_a?(String)
    rescue NoMethodError
      false
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
    end

    # Inline adapter methods for registry dispatch

    def render_em(el)
      render_inline_tag("em", el)
    end

    def render_strong(el)
      render_inline_tag("strong", el)
    end

    def render_tt(el)
      render_inline_tag("tt", el)
    end

    def render_sub(el)
      render_inline_tag("sub", el)
    end

    def render_sup(el)
      render_inline_tag("sup", el)
    end

    def render_small_caps(el)
      render_inline_tag("span", el, class: "small-caps")
    end

    def render_underline(el)
      render_inline_tag("u", el)
    end

    def render_strike(el)
      render_inline_tag("s", el)
    end

    def render_br(*)
      @output << "<br />"
    end

    def render_tab(*)
      @output << "\u00a0\u00a0"
    end

    def render_span(el)
      xml_class = safe_attr(el, :class_attr).to_s
      html_class = html_class_for_span(xml_class) unless xml_class.empty?
      attrs = element_attrs(style: safe_attr(el, :style), class: html_class)
      tag("span", attrs) { render_mixed_inline(el) }
    end

    def render_fn_inline(el)
      render_fn(el)
    end

    def render_stem(el)
      # StemElement in presentation XML is always paired with FmtStemElement
      # which renders the formatted version — skip the raw stem to avoid duplication
    end

    def render_semx_inline(el)
      render_semx_content(el)
    end

    def render_fmt_xref(el)
      target = safe_attr(el, :target) || safe_attr(el, :to_attr)
      if target
        attrs = element_attrs(href: "##{escape_html(target)}", class: "xref")
        tag("a", attrs) { render_mixed_inline(el) }
      else
        render_mixed_inline(el)
      end
    end

    def render_comma(*)
      @output << ", "
    end

    def render_math(el)
      @output << el.content.to_s
    end

    def render_asciimath(el)
      @output << %(<span class="stem">#{escape_html(Array(el.text).join)}</span>)
    end

    def render_index(el)
      collect_index_term(el)
      ""
    end

    def render_note_inline(el)
      render_note(el)
    end

    def render_inline_collections(node)
      texts = node.text
      if texts.is_a?(Array)
        texts.each do |t|
          if t.is_a?(String)
            @output << escape_html(t)
          else
            render_inline_element(t)
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
    def render_semx_content(element, **_opts)
      display_attrs = %i[text fmt_xref fmt_link fmt_concept span strong em sup p semx
                         asciimath math sub_child tt_child br_child tab_child
                         stem_child figure_child formula_child sourcecode_child]
      label_stripped = false

      walked = walk_ordered(element,
                            allow_filter: display_attrs) do |type, obj|
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
      return semx_text unless tail&.rstrip&.end_with?(first_word)

      semx_text.sub(/\A\s*#{Regexp.escape(first_word)}\s*/, "")
    end

    def render_inline_tag(tag_name, element, **extra_attrs)
      tag(tag_name, element_attrs(**extra_attrs)) do
        render_mixed_inline(element)
      end
    end

    # Process raw XML content from map_all_content models.
    # Strips source elements (xref, eref, stem) that have a following <semx>
    # wrapper, keeping only the semx display content.
    def render_raw_content(raw_xml)
      doc = Nokogiri::XML.fragment(raw_xml)
      # Convert fmt-link elements to HTML <a> tags before stripping wrappers
      doc.css("fmt-link").each do |el|
        target = el["target"] || el["href"]
        if target
          display_text = target.delete_prefix("mailto:")
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
        next unless next_sib&.element? && next_sib.name == "semx"

        deduplicate_semx_label(node, next_sib)
        node.remove
      end
      # Strip presentation wrappers, keeping inner content
      %w[semx fmt-xref].each do |tag|
        doc.css(tag).each { |el| el.replace(el.children) }
      end
      # Remap XML class names to HTML-specific class names
      doc.css("[class]").each do |el|
        el["class"] = el["class"].split(/\s+/).map do |c|
          html_class_for_span(c)
        end.join(" ")
      end
      doc.inner_html
    end

    def deduplicate_semx_label(source_node, semx_node)
      first_text = semx_node.children.find do |c|
        c.text? && !c.text.strip.empty?
      end
      return unless first_text

      semx_prefix = first_text.text[/\A(\s*\S+)/, 1]
      return unless semx_prefix && !semx_prefix.strip.empty?

      prev = source_node.previous_sibling
      return unless prev.is_a?(Nokogiri::XML::Text)

      label = semx_prefix.strip
      prev_text = prev.text.rstrip
      return unless prev_text.end_with?(label)

      prev.content = prev_text.sub(/#{Regexp.escape(label)}\s*\z/, "")
      first_text.content = first_text.text.sub(
        /\A\s*#{Regexp.escape(label)}\s*/, ""
      )
    end

    def render_link(link)
      target = safe_attr(link, :target) || safe_attr(link, :href)
      attrs = element_attrs(href: target, id: safe_attr(link, :id))
      tag("a", attrs) do
        content = safe_attr(link, :content)
        if content && !Array(content).join.strip.empty?
          render_mixed_inline(link)
        else
          display_text = target.to_s.delete_prefix("mailto:")
          @output << escape_html(display_text)
        end
      end
    end

    def render_xref(xref)
      target = safe_attr(xref, :target) || safe_attr(xref, :to_attr)
      attrs = element_attrs(href: "##{escape_html(target)}",
                            id: safe_attr(xref,
                                          :id))
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

      label = safe_attr(fn, :fn_label) || safe_attr(fn, :reference)
      return unless label

      popup_html = capture_output do
        Array(fn.p).each do |para|
          render_mixed_inline(para)
        end
      end

      assigns = {
        "attrs" => element_attrs(id: fn_id, class: "fn-marker"),
        "number" => number,
        "label" => escape_html(label.to_s),
        "popup_html" => popup_html.strip.empty? ? nil : popup_html,
      }
      @output << render_liquid("_fn_marker.html.liquid", assigns)
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
          math_val = stem.math
          if math_val.respond_to?(:to_xml)
            @output << math_val.to_xml
            return
          end

          text = extract_text_value(math_val)
          @output << %(<span class="stem">#{escape_html(text)}</span>)
          return
        elsif stem.asciimath
          text = extract_text_value(stem.asciimath)
          @output << %(<span class="stem">#{escape_html(text)}</span>)
          return
        end
        if stem.latexmath
          text = extract_text_value(stem.latexmath)
          @output << %(<span class="stem">#{escape_html(text)}</span>)
          return
        end
      end

      text = extract_text_value(stem)
      @output << %(<span class="stem">#{escape_html(text)}</span>) unless text.empty?
    end
    end
  end
end
