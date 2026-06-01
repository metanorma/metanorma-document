# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Inline
        MARK_MAP = {
          "em" => Mark::Emphasis,
          "strong" => Mark::Strong,
          "sub" => Mark::Subscript,
          "sup" => Mark::Superscript,
          "tt" => Mark::Code,
          "underline" => Mark::Underline,
          "strike" => Mark::Strike,
          "smallcap" => Mark::SmallCap,
        }.freeze

        MARK_ATTR_MAP = {
          "link" => { mark_class: Mark::Link, href: :target },
          "xref" => { mark_class: Mark::Xref, target: :target },
          "eref" => { mark_class: Mark::Eref },
          "fn" => { mark_class: Mark::Footnote },
          "stem" => { mark_class: Mark::Stem },
          "stem_inline" => { mark_class: Mark::Stem },
          "concept" => { mark_class: Mark::Concept },
          "bcp14" => { mark_class: Mark::Bcp14 },
          "span" => { mark_class: Mark::Span },
        }.freeze

        SEMX_MARK_CONFIG = {
          "xref" => { mark_class: Mark::Xref, target_attr: :target,
                      fmt_attr: :fmt_xref },
          "eref" => { mark_class: Mark::Eref, target_attr: :target,
                      fmt_attr: :fmt_xref },
          "link" => { mark_class: Mark::Link, target_attr: :target,
                      fmt_attr: :fmt_link },
        }.freeze

        def self.extract_inline(element, context:)
          nodes = []
          element.each_mixed_content do |node|
            case node
            when String
              nodes << context.text_node(node) unless node.strip.empty?
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

          element_name = derive_element_name(element)
          mark = build_mark(element_name, element)
          if mark
            text = extract_marked_text(element_name, element)
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
          mark = config[:mark_class].new(attrs: mark_attrs.compact)
          nodes << context.text_node(text, marks: [mark])
        end

        def self.handle_block_in_inline(element, nodes, context:)
          result = context.registry.handle(element, context: context)
          return unless result && result[0]

          if result[1]
            nodes.concat(Array(result[0]))
          else
            nodes << result[0]
          end
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

        def self.build_mark(name, element)
          mark_class = MARK_MAP[name]
          if mark_class
            return mark_class.new
          end

          config = MARK_ATTR_MAP[name]
          return nil unless config

          mark_class = config[:mark_class]
          attrs = {}

          case name
          when "link"
            attrs[:href] =
              SafeAttr.read(element, :target) || SafeAttr.read(element, :href)
          when "xref"
            attrs[:target] = SafeAttr.read(element, :target)
          when "eref"
            attrs[:bibitemid] = SafeAttr.read(element, :bibitemid)
            attrs[:citeas] = SafeAttr.read(element, :citeas)
          when "fn"
            attrs[:id] = SafeAttr.read(element, :id)
            attrs[:reference] = SafeAttr.read(element, :reference)
          when "stem", "stem_inline"
            attrs[:stem_type] = SafeAttr.read(element, :stem_type) || "MathML"
            math = SafeAttr.read(element, :math)
            if math
              xml = math.is_a?(Array) ? math.map(&:to_xml).join : math.to_xml
              attrs[:mathml] = xml.sub(/\A<\?xml[^?]*\?>\s?/, "")
            end
          when "concept"
            attrs[:refterm] = SafeAttr.read(element, :refterm)
            attrs[:renderterm] = SafeAttr.read(element, :renderterm)
          when "span"
            attrs[:class_attr] = SafeAttr.read(element, :class_attr)
            attrs[:style] = SafeAttr.read(element, :style)
          end

          mark_class.new(attrs: attrs.compact)
        end

        # Text extraction for marked inline elements
        def self.extract_marked_text(element_name, element)
          case element_name
          when "fn"
            extract_fn_label(element)
          when "stem", "stem_inline"
            extract_stem_text(element)
          when "span"
            extract_span_text(element)
          else
            extract_element_text(element)
          end
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

        # Extract text from formatting elements preserving document order.
        # Uses element_order directly because each_mixed_content skips whitespace.
        def self.extract_formatted_text(element)
          return "" unless element

          if element.respond_to?(:element_order) && element.element_order
            parts = []
            collection_indices = ::Hash.new(0)
            element.element_order.each do |el|
              if el.text?
                text = el.text_content
                parts << text if text
              elsif el.element?
                child_text = resolve_ordered_child_text(element, el.name,
                                                        collection_indices)
                parts << child_text if child_text
              end
            end
            return parts.join.strip
          end

          extract_text_from_attrs(element)
        end

        def self.resolve_ordered_child_text(element, el_name, indices)
          xml_mapping = element.class.mappings_for(:xml,
                                                   element.lutaml_register)
          return nil unless xml_mapping

          attr_name = nil
          xml_mapping.mapping_elements_hash.each_value do |rule_or_array|
            Array(rule_or_array).each do |rule|
              if rule.name.to_s == el_name || rule.name == el_name.to_sym
                attr_name = rule.to
                break
              end
            end
            break if attr_name
          end
          return nil unless attr_name

          collection = element.send(attr_name)
          return nil unless collection.is_a?(Array) && !collection.empty?

          idx = indices[attr_name]
          indices[attr_name] += 1
          child = collection[idx]
          child ? extract_text_from_model(child) : nil
        end

        def self.extract_text_from_model(node)
          case node.class.name
          when /TabElement$/
            " "
          when /BrElement$/
            "\n"
          else
            # Most elements can contain mixed content — try formatted text first
            text = extract_formatted_text(node)
            text.empty? ? extract_text_from_attrs(node) : text
          end
        end

        def self.extract_text_from_attrs(element)
          return "" unless element.is_a?(Lutaml::Model::Serializable)

          text = SafeAttr.read(element, :text)
          if text.is_a?(Array)
            joined = text.join
            return joined unless joined.strip.empty?
          elsif text.is_a?(String) && !text.strip.empty?
            return text
          end

          content = SafeAttr.read(element, :content)
          if content.is_a?(Array)
            parts = content.filter_map do |c|
              next c.to_s if c.is_a?(String)
              next extract_text_from_attrs(c) if c.is_a?(Lutaml::Model::Serializable)

              nil
            end
            return parts.join unless parts.join.strip.empty?
          elsif content.is_a?(String) && !content.strip.empty?
            return content
          end

          ""
        end

        def self.semx_element?(element)
          element.class.name&.end_with?("::SemxElement")
        end

        def self.block_in_inline?(element, context)
          context.registry.registered?(element.class)
        end

        def self.derive_element_name(element)
          element.class.name.split("::").last
            .gsub(/([A-Z])/, '_\1')
            .downcase
            .sub(/^_/, "")
            .sub(/_element$/, "")
        end

        def self.filter_empty_crossrefs(nodes)
          crossref_marks = %w[xref eref link].to_set
          nodes.delete_if do |n|
            n.is_a?(Node::Text) &&
              n.text.to_s.strip.empty? &&
              n.marks.any? { |m| crossref_marks.include?(m.type) }
          end
          nodes
        end
      end
    end
  end
end
