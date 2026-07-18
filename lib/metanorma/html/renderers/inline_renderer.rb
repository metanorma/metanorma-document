# frozen_string_literal: true

module Metanorma
  module Html
    module Renderers
      class InlineRenderer
        def initialize(coordinator)
          @coordinator = coordinator
        end

        def walk_ordered(node, allow_filter: nil)
          return false unless node.is_a?(Lutaml::Model::Serializable)
          return false unless node.element_order.is_a?(Array) && !node.element_order.empty?

          xml_mapping = node.class.mappings_for(:xml, node.lutaml_register)
          return false unless xml_mapping

          element_to_attr =
            Renderers::ElementOrderTraversal.element_to_attr_map(xml_mapping)

          skip_indices = build_semx_skip_set(node)

          indices = Hash.new(0)

          node.element_order.each_with_index do |el, i|
            next if skip_indices.include?(i)

            if el.text?
              text = el.text_content
              yield :text, text if text && block_given?
            elsif el.element?
              if el.name == "tab"
                yield :tab, nil if block_given?
                next
              end

              attr_name = element_to_attr[el.name]
              next unless attr_name

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

        def render_cell_content(cell)
          parts = []
          walked = walk_ordered(cell) do |type, obj|
            case type
            when :text
              parts << escape_html(obj)
            when :tab
              parts << "  "
            when :element
              parts << if coordinator.block_element?(obj)
                         coordinator.render(obj) || ""
                       else
                         render_inline_element(obj) || ""
                       end
            end
          end
          unless walked
            parts << (render_mixed_content_in_order(cell) || "")
          end
          parts.join
        end

        def render_mixed_inline(node)
          if node.is_a?(Lutaml::Model::Serializable) && node.element_order && !node.element_order.empty?
            render_ordered_inline(node)
          elsif node.is_a?(Lutaml::Model::Serializable)
            parts = []
            node.each_mixed_content do |child|
              parts << case child
                       when String
                         escape_html(child)
                       else
                         render_inline_element(child) || ""
                       end
            end
            parts.join
          else
            render_inline_collections(node)
          end
        end

        def render_ordered_inline(node)
          parts = []
          walked = walk_ordered(node) do |type, obj|
            case type
            when :text
              parts << escape_html(obj)
            when :tab
              parts << "  "
            when :element
              parts << (render_inline_element(obj) || "")
            end
          end
          unless walked
            node.each_mixed_content do |child|
              parts << case child
                       when String
                         escape_html(child)
                       else
                         render_inline_element(child) || ""
                       end
            end
          end
          parts.join
        end

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
          render_liquid("_br.html.liquid", {})
        end

        def render_tab(*)
          "  "
        end

        def render_span(el)
          xml_class = safe_attr(el, :class_attr).to_s
          html_class = html_class_for_span(xml_class) unless xml_class.empty?
          attrs = element_attrs(style: safe_attr(el, :style), class: html_class)
          content = render_mixed_inline(el)
          render_liquid("_inline_span.html.liquid", {
                          "attrs" => attrs,
                          "content" => content,
                        })
        end

        def render_fn_inline(el)
          render_fn(el)
        end

        def render_stem(_el)
          nil
        end

        def render_semx_inline(el)
          render_semx_content(el)
        end

        def render_fmt_xref(el)
          target = safe_attr(el, :target) || safe_attr(el, :to_attr)
          if target
            attrs = element_attrs(href: "##{escape_html(target)}",
                                  class: "xref")
            content = render_mixed_inline(el)
            render_liquid("_link.html.liquid", {
                            "attrs" => attrs,
                            "content" => content,
                          })
          else
            render_mixed_inline(el)
          end
        end

        def render_comma(*)
          ", "
        end

        # Form inputs render as disabled HTML inputs — this is a document
        # rendering, not an interactive form.
        def render_input(el)
          attrs = element_attrs(
            type: safe_attr(el, :type) || "text",
            disabled: "disabled",
            checked: safe_attr(el, :checked) ? "checked" : nil,
          )
          "<input#{attrs}>"
        end

        def render_math(el)
          el.to_xml
        end

        def render_asciimath(el)
          text = escape_html(Array(el.text).join)
          render_liquid("_stem_span.html.liquid", {
                          "data_attrs" => "",
                          "text" => text,
                        })
        end

        def render_index(el)
          collect_index_term(el)
          nil
        end

        def render_note_inline(el)
          coordinator.render_note(el)
        end

        def render_bookmark(bookmark, **)
          coordinator.render_bookmark(bookmark, **)
        end

        def render_image(image)
          coordinator.render_image(image)
        end

        def render_noop_inline(*)
          nil
        end

        def render_inline_collections(node)
          parts = []
          texts = node.text
          if texts.is_a?(Array)
            texts.each do |t|
              parts << if t.is_a?(String)
                         escape_html(t)
                       else
                         render_inline_element(t) || ""
                       end
            end
          elsif texts.is_a?(String)
            parts << escape_html(texts)
          end

          # Derive the element-mapped attribute list from the node's own
          # xml_mapping rather than maintaining a parallel hardcoded list.
          # The model is the single source of truth; adding a new inline
          # element type via map_element on the model class is enough.
          node.class.mappings[:xml].elements.each do |rule|
            next if rule.to == :text

            values = safe_attr(node, rule.to)
            next if values.nil?

            Array(values).each { |v| parts << (render_inline_element(v) || "") }
          end
          parts.join
        end

        def render_semx_content(element, **_opts)
          parts = []
          display_attrs = %i[text fmt_xref fmt_link fmt_concept span strong em sup p semx
                             asciimath math sub_child tt_child br_child tab_child
                             stem_child figure_child formula_child sourcecode_child]
          label_stripped = false

          walked = walk_ordered(element,
                                allow_filter: display_attrs) do |type, obj|
            case type
            when :text
              text = obj
              unless label_stripped
                text = deduplicate_semx_text(text, parts.join)
                label_stripped = true
              end
              parts << escape_html(text)
            when :element
              parts << if obj.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
                         coordinator.render_paragraph(obj) || ""
                       else
                         render_inline_element(obj) || ""
                       end
            end
          end

          unless walked
            display_attrs.each do |attr|
              val = safe_attr(element, attr)
              next if val.nil?

              if val.is_a?(Array)
                val.each do |v|
                  parts << if v.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
                             coordinator.render_paragraph(v) || ""
                           else
                             render_inline_element(v) || ""
                           end
                end
              elsif val.is_a?(String)
                parts << escape_html(val)
              else
                parts << (render_inline_element(val) || "")
              end
            end
          end
          parts.join
        end

        def deduplicate_semx_text(semx_text, rendered_so_far)
          first_word = semx_text[/\A\s*(\S+)/, 1]
          return semx_text unless first_word

          tail = rendered_so_far[-200..]
          return semx_text unless tail&.rstrip&.end_with?(first_word)

          semx_text.sub(/\A\s*#{Regexp.escape(first_word)}\s*/, "")
        end

        def render_inline_tag(tag_name, element, **extra_attrs)
          content = render_mixed_inline(element)
          render_liquid("_element.html.liquid", {
                          "tag" => tag_name,
                          "extra_attrs" => element_attrs(**extra_attrs),
                          "content" => content,
                        })
        end

        def render_link(link)
          target = safe_attr(link, :target) || safe_attr(link, :href)
          attrs = element_attrs(href: target, id: safe_attr(link, :id))
          content = safe_attr(link, :content)
          if content && !Array(content).join.strip.empty?
            inner = render_mixed_inline(link)
            render_liquid("_link.html.liquid", {
                            "attrs" => attrs,
                            "content" => inner,
                          })
          else
            display_text = escape_html(target.to_s.delete_prefix("mailto:"))
            render_liquid("_link.html.liquid", {
                            "attrs" => attrs,
                            "display_text" => display_text,
                          })
          end
        end

        def render_xref(xref)
          target = safe_attr(xref, :target) || safe_attr(xref, :to_attr)
          attrs = element_attrs(href: "##{escape_html(target)}",
                                id: safe_attr(xref, :id))
          content = render_mixed_inline(xref)
          render_liquid("_link.html.liquid", {
                          "attrs" => attrs,
                          "content" => content,
                        })
        end

        def render_eref(eref)
          citeas = safe_attr(eref, :citeas)
          if citeas
            escape_html(citeas)
          else
            render_mixed_inline(eref)
          end
        end

        def render_fn(fn)
          fn_id = safe_attr(fn, :id)
          number = coordinator.footnote_collector.register(fn)

          label = safe_attr(fn, :fn_label) || safe_attr(fn, :reference)
          return nil unless label

          popup_parts = Array(fn.p).map do |para|
            render_mixed_inline(para) || ""
          end
          popup_html = popup_parts.join

          assigns = {
            "attrs" => element_attrs(id: fn_id, class: "fn-marker"),
            "number" => number,
            "label" => escape_html(label.to_s),
            "popup_html" => popup_html.strip.empty? ? nil : popup_html,
          }
          render_liquid("_fn_marker.html.liquid", assigns)
        end

        def render_concept(concept)
          render_mixed_inline(concept)
        end

        def render_fmt_stem(fmt_stem)
          semx_items = Array(fmt_stem.semx)
          return nil if semx_items.empty?

          semx = semx_items.first
          math_items = Array(semx.math)
          ascii_items = Array(semx.asciimath)

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
            content = math_items.map(&:to_xml).join
            unless content.empty?
              return render_liquid("_math_container.html.liquid", {
                                     "data_attrs" => data_attrs,
                                     "content" => content,
                                   })
            end
          elsif ascii_items.any?
            text = escape_html(ascii_items.map { |a| a.text.to_s.strip }.join)
            return render_liquid("_stem_span.html.liquid", {
                                   "data_attrs" => data_attrs,
                                   "text" => text,
                                 })
          end
          nil
        end

        # Stem content formats in priority order. Each entry binds an
        # attribute reader on the stem element to the value-render path
        # (raw XML when serializable, escaped text otherwise). Adding a
        # new format = one entry here.
        STEM_FORMATS = [
          { attr: :math, raw_xml: true },
          { attr: :asciimath },
          { attr: :latexmath },
        ].freeze

        def render_stem_content(stem)
          return nil if stem.nil?

          return nil if stem.is_a?(Metanorma::Document::Components::Inline::StemInlineElement) ||
            stem.is_a?(Metanorma::Document::Components::Inline::FmtStemElement)

          unless stem.is_a?(Metanorma::Document::Components::TextElements::StemElement)
            text = coordinator.extract_text_value(stem)
            unless text.empty?
              return render_liquid("_stem_span.html.liquid", {
                                     "data_attrs" => "",
                                     "text" => escape_html(text),
                                   })
            end
            return nil
          end

          STEM_FORMATS.each do |format|
            value = stem.public_send(format[:attr])
            next unless value

            if format[:raw_xml] && value.is_a?(Lutaml::Model::Serializable)
              return value.to_xml
            end

            return render_liquid("_stem_span.html.liquid", {
                                   "data_attrs" => "",
                                   "text" => escape_html(coordinator.extract_text_value(value)),
                                 })
          end
          nil
        end

        def render_inline_element(element, **)
          return nil if element.nil?

          if element.is_a?(String)
            return escape_html(element)
          end

          method = coordinator.lookup_dispatch(element.class, :inline_registry)
          if method
            coordinator.public_send(method, element)
          elsif element.is_a?(Lutaml::Model::Serializable) && element.mixed?
            render_mixed_inline(element)
          end
        end

        def render_mixed_content_in_order(node, skip_classes: nil)
          parts = []
          node.each_mixed_content do |child|
            next if skip_classes&.any? { |klass| child.is_a?(klass) }

            parts << case child
                     when String
                       escape_html(child)
                     else
                       if coordinator.block_element?(child)
                         coordinator.render(child) || ""
                       else
                         render_inline_element(child) || ""
                       end
                     end
          end
          parts.join
        end

        private

        attr_reader :coordinator

        def safe_attr(obj, method_name)
          coordinator.safe_attr(obj, method_name)
        end

        def escape_html(text)
          coordinator.escape_html(text)
        end

        def element_attrs(**attrs)
          coordinator.element_attrs(**attrs)
        end

        def render_liquid(template_name, assigns)
          coordinator.render_liquid(template_name, assigns)
        end

        def html_class_for_span(xml_class)
          coordinator.html_class_for_span(xml_class)
        end

        def collect_index_term(element)
          coordinator.collect_index_term(element)
        end
      end
    end
  end
end
