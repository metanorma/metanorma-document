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
            registry.register_node_handler("paragraph", instance_method(:render_paragraph))
            registry.register_node_handler("note", instance_method(:render_note))
            registry.register_node_handler("admonition", instance_method(:render_admonition))
            registry.register_node_handler("example", instance_method(:render_example))
            registry.register_node_handler("figure", instance_method(:render_figure))
            registry.register_node_handler("image", instance_method(:render_image))
            registry.register_node_handler("sourcecode", instance_method(:render_sourcecode))
            registry.register_node_handler("formula", instance_method(:render_formula))
            registry.register_node_handler("quote", instance_method(:render_quote))
            registry.register_node_handler("review", instance_method(:render_review))
            registry.register_node_handler("term", instance_method(:render_term))
          end

          def render_paragraph(node, depth: 0)
            HtmlRenderers.build do |doc|
              attrs = { class: "mn-paragraph" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.p(attrs) { HtmlRenderers.embed(doc, render_inline(node.content)) }
            end
          end

          def render_note(node, depth: 0)
            HtmlRenderers.build do |doc|
              attrs = { class: "mn-note" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.div(attrs) do
                doc.div(class: "note-title") { doc.text "Note" }
                HtmlRenderers.embed(doc, render_children(node, depth:))
              end
            end
          end

          def render_admonition(node, depth: 0)
            adm_type = node.attrs["type"] || "note"
            title = ADMONITION_TITLES[adm_type] || adm_type.capitalize

            HtmlRenderers.build do |doc|
              attrs = { class: "mn-admonition mn-admonition--#{adm_type}" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.div(attrs) do
                doc.div(class: "admonition-content") do
                  doc.div(class: "admonition-title") { doc.text title }
                  HtmlRenderers.embed(doc, render_children(node, depth:))
                end
              end
            end
          end

          def render_example(node, depth: 0)
            HtmlRenderers.build do |doc|
              attrs = { class: "mn-example" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.div(attrs) { HtmlRenderers.embed(doc, render_children(node, depth:)) }
            end
          end

          def render_figure(node, depth: 0)
            HtmlRenderers.build do |doc|
              attrs = { class: "mn-figure" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.figure(attrs) do
                HtmlRenderers.embed(doc, render_children(node, depth:))
                if node.attrs["title"]
                  doc.figcaption { doc.text node.attrs["title"] }
                end
              end
            end
          end

          def render_image(node, depth: 0)
            HtmlRenderers.build do |doc|
              attrs = {
                src: node.attrs["src"] || "",
                alt: node.attrs["alt"] || "",
                loading: "lazy",
              }
              attrs[:height] = node.attrs["height"] if node.attrs["height"]
              attrs[:width] = node.attrs["width"] if node.attrs["width"]
              doc.img(attrs)
            end
          end

          def render_sourcecode(node, depth: 0)
            lang = node.attrs["language"]
            lang_class = lang ? " language-#{lang}" : ""

            HtmlRenderers.build do |doc|
              attrs = { class: "mn-sourcecode#{lang_class}" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.div(attrs) do
                doc.span(class: "code-language-badge") { doc.text lang } if lang
                doc.pre(class: "code-block") do
                  doc.code { doc.text node.attrs["text"] || "" }
                end
              end
            end
          end

          def render_formula(node, depth: 0)
            HtmlRenderers.build do |doc|
              attrs = { class: "mn-formula" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.div(attrs) do
                doc.span(class: "formula-math") do
                  math = node.attrs["mathml"]
                  if math
                    HtmlRenderers.embed(doc, math)
                  elsif node.attrs["asciimath"]
                    doc.text node.attrs["asciimath"]
                  else
                    doc.text node.attrs["math_text"] || ""
                  end
                end
              end
            end
          end

          def render_quote(node, depth: 0)
            HtmlRenderers.build do |doc|
              attrs = { class: "mn-quote" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.blockquote(attrs) { HtmlRenderers.embed(doc, render_children(node)) }
            end
          end

          def render_review(_node, depth: 0)
            ""
          end

          def render_term(node, depth: 0)
            HtmlRenderers.build do |doc|
              attrs = { class: "mn-term" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.div(attrs) { HtmlRenderers.embed(doc, render_children(node, depth: depth + 1)) }
            end
          end
        end
      end
    end
  end
end
