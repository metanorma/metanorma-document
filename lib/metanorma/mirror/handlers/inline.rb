# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Inline
        # Element class → lambda that builds a mark hash from the element
        MARK_BUILDERS = {
          Metanorma::Document::Components::Inline::EmRawElement => ->(_el) {
            Handlers.build_mark("emphasis")
          },
          Metanorma::Document::Components::Inline::StrongRawElement => ->(_el) {
            Handlers.build_mark("strong")
          },
          Metanorma::Document::Components::Inline::SubElement => ->(_el) {
            Handlers.build_mark("subscript")
          },
          Metanorma::Document::Components::Inline::SupElement => ->(_el) {
            Handlers.build_mark("superscript")
          },
          Metanorma::Document::Components::Inline::TtElement => ->(_el) {
            Handlers.build_mark("code")
          },
          Metanorma::Document::Components::TextElements::UnderlineElement => ->(_el) {
            Handlers.build_mark("underline")
          },
          Metanorma::Document::Components::TextElements::StrikeElement => ->(_el) {
            Handlers.build_mark("strike")
          },
          Metanorma::Document::Components::Inline::SmallCapElement => ->(_el) {
            Handlers.build_mark("smallcap")
          },
          Metanorma::Document::Components::Inline::Bcp14Element => ->(_el) {
            Handlers.build_mark("bcp14")
          },
          Metanorma::Document::Components::Inline::LinkElement => ->(el) {
            attrs = {
              href: SafeAttr.read(el, :target) || SafeAttr.read(el, :href),
            }.compact
            Handlers.build_mark("link", attrs: attrs)
          },
          Metanorma::Document::Components::Inline::XrefElement => ->(el) {
            attrs = { target: SafeAttr.read(el, :target) }.compact
            Handlers.build_mark("xref", attrs: attrs)
          },
          Metanorma::Document::Components::Inline::ErefElement => ->(el) {
            attrs = {
              bibitemid: SafeAttr.read(el, :bibitemid),
              citeas: SafeAttr.read(el, :citeas),
            }.compact
            Handlers.build_mark("eref", attrs: attrs)
          },
          Metanorma::Document::Components::Inline::FnElement => ->(el) {
            attrs = {
              id: SafeAttr.read(el, :id),
              reference: SafeAttr.read(el, :reference),
            }.compact
            Handlers.build_mark("footnote", attrs: attrs)
          },
          Metanorma::Document::Components::Inline::StemInlineElement => ->(el) {
            attrs = { stem_type: SafeAttr.read(el, :stem_type) || "MathML" }
            math = SafeAttr.read(el, :math)
            attrs[:mathml] = Handlers.mathml_from_math(math) if math
            Handlers.build_mark("stem", attrs: attrs.compact)
          },
          Metanorma::Document::Components::Inline::ConceptElement => ->(el) {
            attrs = {
              refterm: SafeAttr.read(el, :refterm),
              renderterm: SafeAttr.read(el, :renderterm),
            }.compact
            Handlers.build_mark("concept", attrs: attrs)
          },
          Metanorma::Document::Components::Inline::SpanElement => ->(el) {
            attrs = {
              class_attr: SafeAttr.read(el, :class_attr),
              style: SafeAttr.read(el, :style),
            }.compact
            Handlers.build_mark("span", attrs: attrs)
          },
        }.freeze

        # Mark type strings that need custom text extraction
        CUSTOM_TEXT_MARKS = {
          "footnote" => :extract_fn_label,
          "stem" => :extract_stem_text,
          "span" => :extract_span_text,
        }.freeze

        SEMX_MARK_CONFIG = {
          "xref" => { mark_type: "xref", target_attr: :target,
                      fmt_attr: :fmt_xref },
          "eref" => { mark_type: "eref", target_attr: :target,
                      fmt_attr: :fmt_xref },
          "link" => { mark_type: "link", target_attr: :target,
                      fmt_attr: :fmt_link },
        }.freeze

        def self.extract_inline(element, context:)
          nodes = []
          element.each_mixed_content do |node|
            case node
            when String
              nodes << context.text_node(node) unless node.empty?
            else
              handle_inline_element(node, nodes, context:)
            end
          end
          filter_empty_crossrefs(nodes)
        end

        def self.handle_inline_element(element, nodes, context:)
          if semx_element?(element)
            handle_semx(element, nodes, context:)
            return
          end

          if block_in_inline?(element, context)
            handle_block_in_inline(element, nodes, context:)
            return
          end

          mark_builder = MARK_BUILDERS[element.class]
          if mark_builder
            mark = mark_builder.call(element)
            text = extract_marked_text(mark["type"], element)
            nodes << context.text_node(text, marks: [mark])
          else
            handle_structured_inline(element, nodes, context:)
          end
        end

        def self.handle_semx(element, nodes, context:)
          config = SEMX_MARK_CONFIG[element.element_attr]
          if config
            handle_semx_crossref(element, config, nodes, context:)
          else
            handle_structured_inline(element, nodes, context:)
          end
        end

        def self.handle_semx_crossref(element, config, nodes, context:)
          fmt_children = SafeAttr.read(element, config[:fmt_attr])
          fmt_child = fmt_children&.first

          mark_attrs = {}
          if fmt_child && config[:target_attr]
            mark_attrs[config[:target_attr]] = SafeAttr.read(fmt_child, :target)
          end

          if element.element_attr == "eref" && fmt_child
            mark_attrs[:citeas] = extract_formatted_text(fmt_child)
          end

          text = extract_formatted_text(fmt_child || element)
          mark = Handlers.build_mark(config[:mark_type], attrs: mark_attrs.compact)
          nodes << context.text_node(text, marks: [mark])
        end

        def self.handle_block_in_inline(element, nodes, context:)
          result = context.registry.handle(element, context: context)
          result.append_to(nodes)
        end

        def self.handle_structured_inline(element, nodes, context:)
          if element.is_a?(Lutaml::Model::Serializable)
            inner_nodes = extract_inline(element, context:)
            nodes.concat(inner_nodes)
          else
            text = element.text
            nodes << context.text_node(text) if text.is_a?(String) && !text.strip.empty?
          end
        end

        def self.extract_marked_text(mark_type, element)
          extractor = CUSTOM_TEXT_MARKS[mark_type]
          return public_send(extractor, element) if extractor

          extract_element_text(element)
        end

        def self.extract_fn_label(element)
          label = SafeAttr.read(element, :fmt_fn_label)
          return extract_element_text(element) unless label

          extract_formatted_text(label)
        end

        def self.extract_stem_text(element)
          asciimath = SafeAttr.read(element, :asciimath)
          if asciimath.is_a?(Array)
            parts = asciimath.filter_map do |a|
              next a if a.is_a?(String)
              next SafeAttr.read(a, :text).to_s if a.is_a?(Lutaml::Model::Serializable)

              nil
            end
            joined = parts.join.strip
            return joined unless joined.empty?
          end
          extract_element_text(element)
        end

        def self.extract_span_text(element)
          text = extract_element_text(element)
          return text unless text.strip.empty?

          extract_formatted_text(element)
        end

        def self.extract_element_text(element)
          return "" unless element.is_a?(Lutaml::Model::Serializable)

          text = SafeAttr.read(element, :text)
          if text.is_a?(Array)
            joined = text.join.strip
            return joined unless joined.empty?
          elsif text.is_a?(String) && !text.strip.empty?
            return text
          end

          content = SafeAttr.read(element, :content)
          if content.is_a?(Array)
            parts = content.filter_map do |c|
              next c.to_s if c.is_a?(String)
              next extract_element_text(c) if c.is_a?(Lutaml::Model::Serializable)

              nil
            end
            joined = parts.join.strip
            return joined unless joined.empty?
          elsif content.is_a?(String) && !content.strip.empty?
            return content
          end

          ""
        end

        def self.extract_formatted_text(element)
          return "" unless element
          return element.to_s unless element.is_a?(Lutaml::Model::Serializable)

          parts = []
          element.each_mixed_content do |node|
            case node
            when String
              parts << node
            when Lutaml::Model::Serializable
              inner = extract_formatted_text(node)
              parts << inner if inner && !inner.empty?
            end
          end
          result = parts.join.strip
          result.empty? ? extract_element_text(element) : result
        end

        def self.extract_text_from_model(node)
          case node
          when Metanorma::Document::Components::Inline::TabElement
            " "
          when Metanorma::Document::Components::Inline::BrElement
            "\n"
          else
            text = extract_formatted_text(node)
            text.empty? ? extract_element_text(node) : text
          end
        end

        def self.semx_element?(element)
          element.is_a?(Metanorma::Document::Components::Inline::SemxElement)
        end

        def self.block_in_inline?(element, context)
          context.registry.registered?(element.class)
        end

        CROSSREF_MARKS = %w[xref eref link].to_set.freeze

        def self.filter_empty_crossrefs(nodes)
          nodes.reject do |n|
            n.is_a?(Hash) && n["type"] == "text" &&
              n["text"].to_s.strip.empty? &&
              Array(n["marks"]).any? { |m| CROSSREF_MARKS.include?(m["type"]) }
          end
        end

        # Class-based rich HTML rendering for inline elements in titles.
        # Each entry maps an element class to either an HTML tag (String)
        # or a method name (Symbol) for custom rendering.
        RICH_HTML_RENDERERS = {
          Metanorma::Document::Components::Inline::EmRawElement => "em",
          Metanorma::Document::Components::Inline::StrongRawElement => "strong",
          Metanorma::Document::Components::Inline::SubElement => "sub",
          Metanorma::Document::Components::Inline::SupElement => "sup",
          Metanorma::Document::Components::Inline::TtElement => "code",
          Metanorma::Document::Components::TextElements::UnderlineElement => "u",
          Metanorma::Document::Components::TextElements::StrikeElement => "s",
          Metanorma::Document::Components::Inline::SmallCapElement => "span",
          Metanorma::Document::Components::Inline::Bcp14Element => "span",
          Metanorma::Document::Components::Inline::StemInlineElement => :rich_html_for_stem,
          Metanorma::Document::Components::TextElements::StemElement => :rich_html_for_stem,
          Metanorma::Document::Components::Inline::XrefElement => :rich_html_for_xref,
          Metanorma::Document::Components::Inline::LinkElement => :rich_html_for_link,
          Metanorma::Document::Components::Inline::ErefElement => :rich_html_for_eref,
          Metanorma::Document::Components::Inline::FnElement => :rich_html_for_fn,
          Metanorma::Document::Components::Inline::ConceptElement => "span",
          Metanorma::Document::Components::Inline::SpanElement => :rich_html_for_span,
          Metanorma::Document::Components::Inline::BrElement => :rich_html_for_br,
        }.freeze

        def self.extract_rich_html(element)
          return "" unless element
          return CGI.escapeHTML(element.to_s) unless element.is_a?(Lutaml::Model::Serializable)

          parts = []
          element.each_mixed_content do |node|
            parts << rich_html_for_node(node)
          end
          result = parts.join.strip
          result.empty? ? extract_element_text(element) : result
        end

        def self.rich_html_for_node(node)
          case node
          when String
            CGI.escapeHTML(node)
          when Lutaml::Model::Serializable
            rich_html_for_element(node)
          else
            ""
          end
        end

        def self.rich_html_for_element(element)
          renderer = RICH_HTML_RENDERERS[element.class]
          if renderer.nil?
            extract_rich_html(element)
          elsif renderer.is_a?(Symbol)
            public_send(renderer, element)
          else
            inner = extract_rich_html(element)
            "<#{renderer}>#{inner}</#{renderer}>"
          end
        end

        def self.rich_html_for_br(_element)
          "<br>"
        end

        def self.rich_html_for_stem(element)
          math = SafeAttr.read(element, :math)
          return extract_element_text(element) unless math

          mathml = Handlers.mathml_from_math(math)
            .sub(/\s*xmlns(:\w+)?="[^"]*"\s*/, " ")
            .gsub(/\s+/, " ")
            .strip
          %{<span class="inline-math">#{mathml}</span>}
        end

        def self.rich_html_for_xref(element)
          target = SafeAttr.read(element, :target) || ""
          label = extract_formatted_text(element)
          label = target if label.strip.empty?
          %{<a href="##{CGI.escapeHTML(target)}">#{CGI.escapeHTML(label)}</a>}
        end

        def self.rich_html_for_link(element)
          href = SafeAttr.read(element, :target) || SafeAttr.read(element, :href) || ""
          label = extract_formatted_text(element)
          %{<a href="#{CGI.escapeHTML(href)}">#{CGI.escapeHTML(label)}</a>}
        end

        def self.rich_html_for_eref(element)
          citeas = SafeAttr.read(element, :citeas) || ""
          label = extract_formatted_text(element)
          %{<a class="eref" cite="#{CGI.escapeHTML(citeas)}">#{CGI.escapeHTML(label)}</a>}
        end

        def self.rich_html_for_fn(element)
          reference = SafeAttr.read(element, :reference) || ""
          %{<sup class="footnote-inline">#{CGI.escapeHTML(reference)}</sup>}
        end

        def self.rich_html_for_span(element)
          cls = SafeAttr.read(element, :class_attr)
          cls_attr = cls ? %( class="#{CGI.escapeHTML(cls)}") : ""
          inner = extract_rich_html(element)
          "<span#{cls_attr}>#{inner}</span>"
        end
      end
    end
  end
end
