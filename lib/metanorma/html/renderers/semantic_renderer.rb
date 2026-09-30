# frozen_string_literal: true

module Metanorma
  module Html
    module Renderers
      # Renders the semantic vocabulary tree (metanorma-extension >
      # metanorma > source > semantic__*-standard): the machine-readable
      # layer whose annexes (glossaries, control catalogs) carry content
      # the presentation tree lacks. Traversal is element_order-driven,
      # so mixed text and children render in document order.
      module SemanticRenderer
        BLOCK_TAGS = %w[
          annex clause terms term p ul ol li dl dt dd note example
          table thead tbody tr td th figure sourcecode title
          definition verbal-definition preferred expression name
          abstract bibliography boilerplate preface sections
        ].freeze
        INLINE_TAGS = %w[
          xref eref link strong em tt underline strike smallcap sub sup
          br concept abbreviation bookmark span fn stem math asciimath
          latexmath mi mn mo mrow mfrac msub msup msubsup mfenced mtext
          mtd mtr mover munderover
        ].freeze

        def render_semantic_annexes(doc)
          roots = semantic_roots(doc)
          return nil unless roots

          parts = roots.filter_map { |root| render_semantic_children(root, level: 1, only: :annex) }
          return nil if parts.empty?

          render_liquid("_element.html.liquid", {
                          "tag" => "div",
                          "extra_attrs" => element_attrs(class: "semantic-annexes"),
                          "content" => parts.join,
                        })
        end

        def semantic_roots(doc)
          ext = safe_attr(doc, :metanorma_extension)
          container = safe_attr(ext, :metanorma)
          source = safe_attr(container, :source)
          roots = Array(safe_attr(source, :semantic_roots))
          roots.empty? ? nil : roots
        end

        private

        def render_semantic_children(node, level:, only: nil)
          parts = []
          each_semantic_child(node) do |name, child|
            next if only && name != only.to_s

            html = render_semantic_node(child, name: name, level: level)
            parts << html if html
          end
          parts.join
        end

        # element_order walk: yields [element_name, child_node] in
        # document order, mapping each occurrence to the corresponding
        # collection item (same indexing scheme as walk_ordered).
        def each_semantic_child(node)
          return enum_for(:each_semantic_child, node) unless block_given?

          name_to_attr = semantic_name_to_attr
          indices = Hash.new(0)
          Array(node.element_order).each do |el|
            next if el.text?

            attr = name_to_attr[el.name]
            next unless attr

            collection = Array(node.public_send(attr))
            child = collection[indices[attr]]
            indices[attr] += 1
            yield el.name, child if child
          end
        end

        def semantic_name_to_attr
          @semantic_name_to_attr ||= Metanorma::Document::Components::Semantic::Node::TAG_ATTRS.to_h
        end

        def render_semantic_node(node, name:, level:)
          case name
          when "annex", "clause" then semantic_section(node, name, level)
          when "terms" then semantic_terms_section(node, level)
          when "term" then semantic_term(node, level)
          when "p", "abstract", "verbal-definition" then semantic_paragraph(node)
          when "ul", "ol" then semantic_list(node, name)
          when "li" then semantic_paragraph(node, tag: "li")
          when "dl" then semantic_dl(node)
          when "note", "example" then semantic_note(node, name)
          when "table" then semantic_table(node)
          when "title" then nil # rendered with its section
          when "figure" then semantic_figure(node)
          else
            semantic_inline_or_plain(node, name) if INLINE_TAGS.include?(name)
          end
        end

        def semantic_section(node, name, level)
          title_html = semantic_title(node, level)
          body = render_semantic_children(node, level: level + 1)
          return nil if title_html.nil? && body.empty?

          tag = name == "annex" ? "section" : "div"
          render_liquid("_element.html.liquid", {
                          "tag" => tag,
                          "extra_attrs" => element_attrs(
                            id: safe_attr(node, :id), class: "semantic-#{name}",
                          ),
                          "content" => "#{title_html}#{body}",
                        })
        end

        def semantic_title(node, level)
          each_semantic_child(node) do |name, child|
            next unless name == "title"

            text = semantic_inline_content(child)
            next if text.strip.empty?

            return render_liquid("_heading.html.liquid", {
                                   "tag" => "h#{[[level, 6].min, 1].max}",
                                   "class_attr" => element_attrs(id: safe_attr(node, :id)),
                                   "content" => text,
                                 })
          end
          nil
        end

        def semantic_terms_section(node, level)
          body = render_semantic_children(node, level: level + 1)
          return nil if body.empty?

          render_liquid("_element.html.liquid", {
                          "tag" => "div",
                          "extra_attrs" => element_attrs(
                            id: safe_attr(node, :id), class: "semantic-terms",
                          ),
                          "content" => body,
                        })
        end

        # A term entry: preferred designations as dt, verbal definition
        # paragraphs as dd — the glossary shape the native render uses.
        def semantic_term(node, _level)
          dts = []
          dds = []
          each_semantic_child(node) do |name, child|
            case name
            when "preferred", "expression", "abbreviation"
              text = semantic_inline_content(child).strip
              dts << %(<dt>#{text}</dt>) unless text.empty?
            when "definition", "verbal-definition", "note", "example"
              inner = render_semantic_children(child, level: 3)
              dds << %(<dd>#{inner}</dd>) unless inner.empty?
            when "p"
              inner = semantic_inline_content(child)
              dds << %(<dd>#{inner}</dd>) unless inner.strip.empty?
            end
          end
          return nil if dts.empty? && dds.empty?

          render_liquid("_element.html.liquid", {
                          "tag" => "dl",
                          "extra_attrs" => element_attrs(
                            id: safe_attr(node, :id), class: "semantic-term",
                          ),
                          "content" => "#{dts.join}#{dds.join}",
                        })
        end

        def semantic_paragraph(node, tag: "p")
          content = semantic_inline_content(node)
          return nil if content.strip.empty?

          render_liquid("_element.html.liquid", {
                          "tag" => tag,
                          "extra_attrs" => element_attrs(id: safe_attr(node, :id)),
                          "content" => content,
                        })
        end

        def semantic_list(node, name)
          items = render_semantic_children(node, level: 2)
          return nil if items.empty?

          render_liquid("_element.html.liquid", {
                          "tag" => name,
                          "extra_attrs" => element_attrs(id: safe_attr(node, :id)),
                          "content" => items,
                        })
        end

        def semantic_dl(node)
          items = render_semantic_children(node, level: 2)
          return nil if items.empty?

          render_liquid("_element.html.liquid", {
                          "tag" => "dl",
                          "extra_attrs" => element_attrs(id: safe_attr(node, :id)),
                          "content" => items,
                        })
        end

        def semantic_note(node, name)
          content = render_semantic_children(node, level: 2)
          content = semantic_inline_content(node) if content.empty?
          return nil if content.strip.empty?

          render_liquid("_element.html.liquid", {
                          "tag" => "div",
                          "extra_attrs" => element_attrs(
                            id: safe_attr(node, :id), class: "semantic-#{name}",
                          ),
                          "content" => content,
                        })
        end

        def semantic_table(node)
          inner = render_semantic_children(node, level: 2)
          return nil if inner.empty?

          render_liquid("_element.html.liquid", {
                          "tag" => "table",
                          "extra_attrs" => element_attrs(id: safe_attr(node, :id)),
                          "content" => inner,
                        })
        end

        def semantic_figure(node)
          each_semantic_child(node) do |name, child|
            next unless name == "image"

            src = safe_attr(child, :url) || safe_attr(child, :href)
            next unless src

            return render_liquid("_element.html.liquid", {
                                   "tag" => "figure",
                                   "extra_attrs" => element_attrs(id: safe_attr(node, :id)),
                                   "content" => %(<img src="#{escape_html(src)}" alt="#{escape_html(safe_attr(child, :alt).to_s)}"/>),
                                 })
          end
          nil
        end

        # Inline content: mixed text and inline children in order.
        def semantic_inline_content(node)
          parts = []
          each_semantic_child(node) do |name, child|
            html = semantic_inline_node(child, name)
            parts << html if html
          end
          semantic_text_nodes(node) + parts_to_html(parts)
        end

        def semantic_inline_node(node, name)
          case name
          when "br" then "<br/>"
          when "xref", "link"
            href = safe_attr(node, :sem_target) || safe_attr(node, :href) ||
                   safe_attr(node, :url)
            text = semantic_inline_content(node)
            text = "[#{escape_html(href.to_s)}]" if text.strip.empty?
            %(<a href="##{escape_html(href.to_s)}">#{text}</a>)
          when "eref"
            semantic_inline_content(node)
          when "strong" then %(<b>#{semantic_inline_content(node)}</b>)
          when "em" then %(<i>#{semantic_inline_content(node)}</i>)
          when "tt" then %(<tt>#{semantic_inline_content(node)}</tt>)
          when "underline" then %(<u>#{semantic_inline_content(node)}</u>)
          when "strike" then %(<s>#{semantic_inline_content(node)}</s>)
          when "smallcap" then %(<span style="font-variant:small-caps">#{semantic_inline_content(node)}</span>)
          when "sub" then %(<sub>#{semantic_inline_content(node)}</sub>)
          when "sup" then %(<sup>#{semantic_inline_content(node)}</sup>)
          else
            text = semantic_inline_content(node)
            text.empty? ? nil : %(<span class="semantic-#{name.tr('_', '-')}">#{text}</span>)
          end
        end

        # The text segments of a mixed-content node, in document order
        # (element_order carries interleaved text nodes).
        def semantic_text_nodes(node)
          Array(node.element_order).select(&:text?).filter_map do |el|
            text = el.text_content
            text && !text.strip.empty? ? escape_html(text) : nil
          end.join
        end

        def parts_to_html(parts)
          parts.compact.join
        end
      end
    end
  end
end
