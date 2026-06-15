# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module BlockRenderers
          ADMONITION_TITLES = {
            "danger" => "Danger", "caution" => "Caution",
            "warning" => "Warning", "important" => "Important",
            "safety precautions" => "Safety Precautions",
            "editorial" => "Editorial",
            "tip" => "Tip", "note" => "Note",
            "commentary" => "Commentary"
          }.freeze

          def self.register(registry)
            registry.register("paragraph", :render_paragraph)
            registry.register("note", :render_note)
            registry.register("admonition", :render_admonition)
            registry.register("example", :render_example)
            registry.register("figure", :render_figure)
            registry.register("image", :render_image)
            registry.register("sourcecode", :render_sourcecode)
            registry.register("formula", :render_formula)
            registry.register("quote", :render_quote)
            registry.register("review", :render_review)
            registry.register("term", :render_term)
          end

          def render_paragraph(node, depth: 0)
            id_attr = build_id_attr(node)
            content = render_inline(node.content)
            %(<p#{id_attr} class="mn-paragraph">#{content}</p>)
          end

          def render_note(node, depth: 0)
            id_attr = build_id_attr(node)
            content = render_children(node, depth:)
            %(<div#{id_attr} class="mn-note">\n  <div class="note-title">Note</div>\n  #{content}\n</div>)
          end

          def render_admonition(node, depth: 0)
            adm_type = node.attrs["type"] || "note"
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
            id_attr = build_id_attr(node)
            title = node.attrs["title"]
            content = render_children(node, depth:)
            caption = title ? %(<figcaption>#{e(title)}</figcaption>) : ""
            %(<figure#{id_attr} class="mn-figure">\n  #{content}\n  #{caption}\n</figure>)
          end

          def render_image(node, depth: 0)
            src = node.attrs["src"] || ""
            alt = node.attrs["alt"] || ""
            height = node.attrs["height"] ? %( height="#{e(node.attrs['height'])}") : ""
            width = node.attrs["width"] ? %( width="#{e(node.attrs['width'])}") : ""
            %(<img src="#{e(src)}" alt="#{e(alt)}"#{height}#{width} loading="lazy" />)
          end

          def render_sourcecode(node, depth: 0)
            id_attr = build_id_attr(node)
            lang = node.attrs["language"]
            lang_class = lang ? " language-#{lang}" : ""
            lang_badge = lang ? %(  <span class="code-language-badge">#{e(lang)}</span>\n) : ""
            code = e(node.attrs["text"] || "")
            %(<div#{id_attr} class="mn-sourcecode#{lang_class}">#{lang_badge}\n  <pre class="code-block"><code>#{code}</code></pre>\n</div>)
          end

          def render_formula(node, depth: 0)
            id_attr = build_id_attr(node)
            math = if node.attrs["mathml"]
                     node.attrs["mathml"]
                   elsif node.attrs["asciimath"]
                     e(node.attrs["asciimath"])
                   else
                     e(node.attrs["math_text"] || "")
                   end
            %(<div#{id_attr} class="mn-formula">\n  <span class="formula-math">#{math}</span>\n</div>)
          end

          def render_quote(node, depth: 0)
            id_attr = build_id_attr(node)
            content = render_children(node)
            %(<blockquote#{id_attr} class="mn-quote">\n  #{content}\n</blockquote>)
          end

          def render_review(_node, depth: 0)
            ""
          end

          def render_term(node, depth: 0)
            id_attr = node.attrs["id"] ? %( id="#{e(node.attrs['id'])}") : ""
            content = render_children(node, depth: depth + 1)
            %(<div#{id_attr} class="mn-term">\n  #{content}\n</div>)
          end
        end
      end
    end
  end
end
