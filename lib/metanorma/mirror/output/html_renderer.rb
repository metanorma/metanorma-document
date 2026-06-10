# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      class HtmlRenderer
        ADMONITION_TITLES = {
          "danger" => "Danger", "caution" => "Caution",
          "warning" => "Warning", "important" => "Important",
          "safety precautions" => "Safety Precautions",
          "editorial" => "Editorial",
          "tip" => "Tip", "note" => "Note",
          "commentary" => "Commentary"
        }.freeze

        class << self
          def custom_node_renderers
            @custom_node_renderers ||= {}
          end

          def register_node_renderer(type, handler)
            custom_node_renderers[type] = handler
          end

          def custom_mark_renderers
            @custom_mark_renderers ||= {}
          end

          def register_mark_renderer(mark_type, handler)
            custom_mark_renderers[mark_type] = handler
          end
        end

        def initialize(guide, numbering: {})
          @guide = guide.is_a?(Hash) ? guide : guide.to_h
          @content = @guide["content"] || []
          @numbering = numbering
        end

        def render
          render_nodes(@content)
        end

        def render_nodes(nodes, depth: 0)
          nodes.filter_map { |node| render_node(node, depth:) }.join("\n")
        end

        def render_node(node, depth: 0)
          type = node["type"]

          custom = self.class.custom_node_renderers[type]
          return custom.call(node, self) if custom

          handler = NODE_RENDERERS[type]
          return public_send(handler, node, depth:) if handler

          render_generic(node, depth:)
        end

        # Section types

        def render_clause(node, depth: 0)
          attrs = node["attrs"] || {}
          id_attr = build_id_attr(node)
          title = attrs["title"]
          number = attrs["number"] || @numbering[attrs["id"]]
          prefix = number ? "#{e(number)} " : ""
          heading = title ? %(<h#{depth + 2}#{id_attr} class="mn-clause__title">#{prefix}#{e(title)}</h#{depth + 2}>) : ""

          content = render_children(node, depth: depth + 1)

          %(<section#{id_attr} class="mn-clause">\n  #{heading}\n  #{content}\n</section>)
        end

        def render_annex(node, depth: 0)
          attrs = node["attrs"] || {}
          id_attr = build_id_attr(node)
          title = attrs["title"]
          heading = title ? %(<h2#{id_attr} class="mn-annex__title">#{e(title)}</h2>) : ""

          content = render_children(node, depth: depth + 1)

          %(<section#{id_attr} class="mn-annex">\n  #{heading}\n  #{content}\n</section>)
        end

        def render_content_section(node, depth: 0)
          attrs = node["attrs"] || {}
          type = node["type"]
          id_attr = build_id_attr(node)
          title = attrs["title"]
          heading = title ? %(<h2#{id_attr} class="mn-#{type}__title">#{e(title)}</h2>) : ""
          content = render_children(node, depth:)
          %(<section#{id_attr} class="mn-#{type}">\n  #{heading}\n  #{content}\n</section>)
        end

        def render_terms(node, depth: 0)
          render_content_section(node, depth:)
        end

        def render_definitions(node, depth: 0)
          render_content_section(node, depth:)
        end

        def render_references(node, depth: 0)
          render_content_section(node, depth:)
        end

        def render_floating_title(node, depth: 0)
          _depth = depth
          attrs = node["attrs"] || {}
          id_attr = build_id_attr(node)
          title = attrs["title"]
          heading_depth = attrs["depth"] || 2
          title ? %(<h#{heading_depth}#{id_attr} class="mn-floating-title">#{e(title)}</h#{heading_depth}>) : ""
        end

        # Block types

        def render_paragraph(node, depth: 0)
          id_attr = build_id_attr(node)
          content = render_inline(node["content"])
          %(<p#{id_attr} class="mn-paragraph">#{content}</p>)
        end

        def render_note(node, depth: 0)
          id_attr = build_id_attr(node)
          content = render_children(node, depth:)
          %(<div#{id_attr} class="mn-note">\n  <div class="note-title">Note</div>\n  #{content}\n</div>)
        end

        def render_admonition(node, depth: 0)
          attrs = node["attrs"] || {}
          adm_type = attrs["type"] || "note"
          id_attr = build_id_attr(node)
          title = ADMONITION_TITLES[adm_type] || adm_type.capitalize
          content = render_children(node, depth:)
          <<~HTML
            <div#{id_attr} class="mn-admonition mn-admonition--#{e(adm_type)}">
            <div class="admonition-content">
            <div class="admonition-title">#{e(title)}</div>
            #{content}
            </div></div>
          HTML
        end

        def render_example(node, depth: 0)
          id_attr = build_id_attr(node)
          content = render_children(node, depth:)
          %(<div#{id_attr} class="mn-example">\n  #{content}\n</div>)
        end

        def render_figure(node, depth: 0)
          attrs = node["attrs"] || {}
          id_attr = build_id_attr(node)
          title = attrs["title"]
          content = render_children(node, depth:)
          caption = title ? %(<figcaption>#{e(title)}</figcaption>) : ""
          %(<figure#{id_attr} class="mn-figure">\n  #{content}\n  #{caption}\n</figure>)
        end

        def render_image(node, depth: 0)
          attrs = node["attrs"] || {}
          src = attrs["src"] || ""
          alt = attrs["alt"] || ""
          height = attrs["height"] ? %( height="#{e(attrs['height'])}") : ""
          width = attrs["width"] ? %( width="#{e(attrs['width'])}") : ""
          %(<img src="#{e(src)}" alt="#{e(alt)}"#{height}#{width} loading="lazy" />)
        end

        def render_sourcecode(node, depth: 0)
          attrs = node["attrs"] || {}
          id_attr = build_id_attr(node)
          lang = attrs["language"]
          lang_class = lang ? " language-#{lang}" : ""
          lang_badge = lang ? %(  <span class="code-language-badge">#{e(lang)}</span>\n) : ""
          code = e(attrs["text"] || "")
          %(<div#{id_attr} class="mn-sourcecode#{lang_class}">#{lang_badge}\n  <pre class="code-block"><code>#{code}</code></pre>\n</div>)
        end

        def render_formula(node, depth: 0)
          attrs = node["attrs"] || {}
          id_attr = build_id_attr(node)

          math = if attrs["mathml"]
                   attrs["mathml"]
                 elsif attrs["asciimath"]
                   e(attrs["asciimath"])
                 else
                   e(attrs["math_text"] || "")
                 end
          %(<div#{id_attr} class="mn-formula">\n  <span class="formula-math">#{math}</span>\n</div>)
        end

        def render_table(node, depth: 0)
          attrs = node["attrs"] || {}
          id_attr = build_id_attr(node)
          title = attrs["title"]
          header = title ? %(<div class="mn-table__header">#{e(title)}</div>) : ""

          content = node["content"] || []
          thead = render_table_section(content.select { |s|
            s["type"] == "table_head"
          }, "th")
          tbody = render_table_section(content.select { |s|
            s["type"] == "table_body"
          }, "td")
          tfoot = render_table_section(content.select { |s|
            s["type"] == "table_foot"
          }, "td")

          %(<div#{id_attr} class="mn-table">#{header}\n  <table>\n#{thead}#{tbody}#{tfoot}\n  </table>\n</div>)
        end

        def render_table_section(sections, cell_tag)
          sections.map do |section|
            rows = (section["content"] || []).map do |row|
              cells = (row["content"] || []).map do |cell|
                cell_attrs = cell["attrs"] || {}
                colspan = cell_attrs["colspan"] ? %( colspan="#{cell_attrs['colspan']}") : ""
                rowspan = cell_attrs["rowspan"] ? %( rowspan="#{cell_attrs['rowspan']}") : ""
                content = render_inline(cell["content"])
                %(<#{cell_tag}#{colspan}#{rowspan}>#{content}</#{cell_tag}>)
              end.join
              %(<tr>#{cells}</tr>)
            end.join("\n")
            wrapper_tag = case section["type"]
                          when "table_head" then "thead"
                          when "table_foot" then "tfoot"
                          else "tbody"
                          end
            %(    <#{wrapper_tag}>\n      #{rows}\n    </#{wrapper_tag}>\n)
          end.join
        end

        def render_quote(node, depth: 0)
          id_attr = build_id_attr(node)
          content = render_children(node)
          %(<blockquote#{id_attr} class="mn-quote">\n  #{content}\n</blockquote>)
        end

        def render_review(_node, depth: 0)
          ""
        end

        # Lists

        def render_bullet_list(node, depth: 0)
          render_list(node, "ul", "mn-bullet-list")
        end

        def render_ordered_list(node, depth: 0)
          render_list(node, "ol", "mn-ordered-list")
        end

        def render_list(node, tag, css_class)
          items = (node["content"] || []).filter_map do |item|
            next render_node(item) unless item["type"] == "list_item"

            content = render_inline(item["content"])
            %(<li class="mn-list-item">#{content}</li>)
          end.join("\n")
          %(<#{tag} class="#{css_class}">\n  #{items}\n</#{tag}>)
        end

        def render_dl(node, depth: 0)
          items = (node["content"] || []).filter_map do |item|
            case item["type"]
            when "dt"
              %(<dt class="mn-dt">#{render_inline(item['content'])}</dt>)
            when "dd"
              %(<dd class="mn-dd">#{render_children(item)}</dd>)
            else
              render_node(item)
            end
          end.join("\n")
          %(<dl class="mn-definition-list">\n  #{items}\n</dl>)
        end

        def render_term(node, depth: 0)
          attrs = node["attrs"] || {}
          id_attr = attrs["id"] ? %( id="#{e(attrs['id'])}") : ""
          content = render_children(node, depth: depth + 1)
          %(<div#{id_attr} class="mn-term">\n  #{content}\n</div>)
        end

        # Structural

        def render_doc(node, depth: 0)
          render_children(node, depth:)
        end

        def render_preface(node, depth: 0)
          content = render_children(node, depth:)
          %(<section class="mn-preface">\n  #{content}\n</section>)
        end

        def render_sections(node, depth: 0)
          content = render_children(node, depth:)
          %(<section class="mn-sections">\n  #{content}\n</section>)
        end

        def render_bibliography(node, depth: 0)
          content = render_children(node, depth:)
          %(<section class="mn-bibliography">\n  #{content}\n</section>)
        end

        # Footnotes

        def render_footnotes(node, depth: 0)
          items = (node["content"] || []).map do |fn|
            id = fn.dig("attrs", "id")
            ref_id = fn.dig("attrs", "ref_id")
            id_attr = id ? %( id="#{e(id)}") : ""
            backref = ref_id ? %( <a href="##{e(ref_id)}">&#8617;</a>) : ""
            content = render_children(fn)
            %(<li#{id_attr}>#{content}#{backref}</li>)
          end.join("\n")
          %(<div class="footnotes"><ol>\n  #{items}\n</ol></div>)
        end

        def render_soft_break(_node, depth: 0)
          "<br />"
        end

        def render_generic(node, depth: 0)
          children = node["content"]
          return "" unless children

          render_children(node, depth:)
        end

        # Inline rendering

        def render_inline(content) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          return "" unless content
          return "" if content.empty?

          content.filter_map do |node|
            if node.is_a?(String)
              e(node)
            elsif node.is_a?(Hash)
              case node["type"]
              when "text"
                render_text_node(node)
              when "footnote_marker"
                attrs = node["attrs"] || {}
                id = attrs["id"]
                ref_id = attrs["ref_id"]
                id_attr = id ? %( id="#{e(id)}") : ""
                %(<sup class="footnote-marker"><a#{id_attr} href="##{e(ref_id || '')}">#{e(attrs['number'] || '*')}</a></sup>)
              when "soft_break"
                "<br />"
              else
                render_node(node)
              end
            end
          end.join
        end

        def render_text_node(node)
          text = e(node["text"] || "")
          marks = node["marks"] || []
          marks.reduce(text) { |current, mark| apply_mark(current, mark) }
        end

        def apply_mark(text, mark)
          mark_type = mark["type"]

          custom = self.class.custom_mark_renderers[mark_type]
          return custom.call(text, mark) if custom

          handler = MARK_RENDERERS[mark_type]
          return handler.call(text, mark) if handler

          text
        end

        MARK_RENDERERS = {
          "emphasis" => ->(text, _mark) { "<em>#{text}</em>" },
          "strong" => ->(text, _mark) { "<strong>#{text}</strong>" },
          "subscript" => ->(text, _mark) { "<sub>#{text}</sub>" },
          "superscript" => ->(text, _mark) { "<sup>#{text}</sup>" },
          "code" => ->(text, _mark) { "<code>#{text}</code>" },
          "underline" => ->(text, _mark) { "<u>#{text}</u>" },
          "strike" => ->(text, _mark) { "<s>#{text}</s>" },
          "smallcap" => ->(text, _mark) {
            "<span style=\"font-variant: small-caps\">#{text}</span>"
          },
          "link" => ->(text, mark) {
            %(<a href="#{escape_attr(mark.dig('attrs',
                                              'href') || '#')}">#{text}</a>)
          },
          "xref" => ->(text, mark) {
            %(<a href="##{escape_attr(mark.dig('attrs',
                                               'target') || '')}">#{text}</a>)
          },
          "eref" => ->(text, mark) {
            %(<a class="eref" cite="#{escape_attr(mark.dig('attrs',
                                                           'citeas') || '')}">#{text}</a>)
          },
          "footnote" => ->(text, _mark) {
            %(<sup class="footnote-inline">#{text}</sup>)
          },
          "stem" => ->(text, _mark) { %(<span class="stem">#{text}</span>) },
          "concept" => ->(text, _mark) {
            %(<span class="concept">#{text}</span>)
          },
          "bcp14" => ->(text, _mark) { %(<span class="bcp14">#{text}</span>) },
          "span" => ->(text, mark) {
            cls = mark.dig("attrs", "class_attr")
            cls_attr = cls ? %( class="#{escape_attr(cls)}") : ""
            %(<span#{cls_attr}>#{text}</span>)
          },
        }.freeze

        def self.escape_attr(text)
          escape_html(text)
        end

        # Helpers

        def render_children(node, depth: 0)
          children = node["content"] || []
          render_nodes(children, depth:)
        end

        def e(text)
          self.class.escape_html(text)
        end

        def build_id_attr(node)
          id = (node["attrs"] || {})["id"]
          id ? %( id="#{e(id)}") : ""
        end

        def self.escape_html(text)
          return "" unless text

          text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub(
            '"', "&quot;"
          )
        end

        NODE_RENDERERS = {
          "doc" => :render_doc,
          "preface" => :render_preface,
          "sections" => :render_sections,
          "bibliography" => :render_bibliography,
          "clause" => :render_clause,
          "annex" => :render_annex,
          "content_section" => :render_content_section,
          "abstract" => :render_content_section,
          "foreword" => :render_content_section,
          "introduction" => :render_content_section,
          "acknowledgements" => :render_content_section,
          "terms" => :render_terms,
          "definitions" => :render_definitions,
          "references" => :render_references,
          "floating_title" => :render_floating_title,
          "paragraph" => :render_paragraph,
          "note" => :render_note,
          "admonition" => :render_admonition,
          "example" => :render_example,
          "figure" => :render_figure,
          "image" => :render_image,
          "sourcecode" => :render_sourcecode,
          "formula" => :render_formula,
          "table" => :render_table,
          "quote" => :render_quote,
          "review" => :render_review,
          "bullet_list" => :render_bullet_list,
          "ordered_list" => :render_ordered_list,
          "dl" => :render_dl,
          "term" => :render_term,
          "footnotes" => :render_footnotes,
          "soft_break" => :render_soft_break,
        }.freeze
      end
    end
  end
end
