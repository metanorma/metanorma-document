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
          "concept" => { mark_class: Mark::Concept },
          "bcp14" => { mark_class: Mark::Bcp14 },
          "span" => { mark_class: Mark::Span },
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
          nodes
        end

        def self.handle_inline_element(element, nodes, context:)
          element_name = element.class.name.split("::").last
            .gsub(/([A-Z])/, '_\1')
            .downcase
            .sub(/^_/, "")
            .sub(/_element$/, "")

          mark = build_mark(element_name, element)
          if mark
            text = extract_element_text(element)
            nodes << context.text_node(text, marks: [mark])
          else
            handle_structured_inline(element, nodes, context:)
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
            attrs[:href] = SafeAttr.read(element, :target) || SafeAttr.read(element, :href)
          when "xref"
            attrs[:target] = SafeAttr.read(element, :target)
          when "eref"
            attrs[:bibitemid] = SafeAttr.read(element, :bibitemid)
            attrs[:citeas] = SafeAttr.read(element, :citeas)
          when "fn"
            attrs[:id] = SafeAttr.read(element, :id)
            attrs[:reference] = SafeAttr.read(element, :reference)
          when "stem"
            attrs[:stem_type] = SafeAttr.read(element, :stem_type) || "MathML"
          when "concept"
            attrs[:refterm] = SafeAttr.read(element, :refterm)
            attrs[:renderterm] = SafeAttr.read(element, :renderterm)
          when "span"
            attrs[:class_attr] = SafeAttr.read(element, :class_attr)
            attrs[:style] = SafeAttr.read(element, :style)
          end

          mark_class.new(attrs: attrs.compact)
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
          end

          ""
        end
      end
    end
  end
end
