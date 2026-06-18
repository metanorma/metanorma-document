# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module SectionRenderers
          def self.register(registry)
            registry.register_node_handler("clause", instance_method(:render_clause))
            registry.register_node_handler("annex", instance_method(:render_annex))
            registry.register_node_handler("content_section", instance_method(:render_content_section))
            registry.register_node_handler("abstract", instance_method(:render_content_section))
            registry.register_node_handler("foreword", instance_method(:render_content_section))
            registry.register_node_handler("introduction", instance_method(:render_content_section))
            registry.register_node_handler("acknowledgements", instance_method(:render_content_section))
            registry.register_node_handler("terms", instance_method(:render_terms))
            registry.register_node_handler("definitions", instance_method(:render_definitions))
            registry.register_node_handler("references", instance_method(:render_references))
            registry.register_node_handler("floating_title", instance_method(:render_floating_title))
          end

          def render_clause(node, depth: 0)
            title = node.attrs["title"]
            number = node.attrs["number"] || @numbering[node.attrs["id"]]

            HtmlRenderers.build do |doc|
              attrs = { class: "mn-clause" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.section(attrs) do
                if title
                  heading_attrs = { class: "mn-clause__title" }
                  heading_attrs[:id] = node.attrs["id"] if node.attrs["id"]
                  doc.send(:"h#{depth + 2}", heading_attrs) do
                    doc.text "#{number} " if number
                    doc.text title
                  end
                end
                HtmlRenderers.embed(doc, render_children(node, depth: depth + 1))
              end
            end
          end

          def render_annex(node, depth: 0)
            title = node.attrs["title"]

            HtmlRenderers.build do |doc|
              attrs = { class: "mn-annex" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.section(attrs) do
                if title
                  heading_attrs = { class: "mn-annex__title" }
                  heading_attrs[:id] = node.attrs["id"] if node.attrs["id"]
                  doc.h2(heading_attrs) { doc.text title }
                end
                HtmlRenderers.embed(doc, render_children(node, depth: depth + 1))
              end
            end
          end

          def render_content_section(node, depth: 0)
            title = node.attrs["title"]
            css_class = "mn-#{node.type}"

            HtmlRenderers.build do |doc|
              attrs = { class: css_class }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.section(attrs) do
                if title
                  heading_attrs = { class: "#{css_class}__title" }
                  heading_attrs[:id] = node.attrs["id"] if node.attrs["id"]
                  doc.h2(heading_attrs) { doc.text title }
                end
                HtmlRenderers.embed(doc, render_children(node, depth:))
              end
            end
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
            title = node.attrs["title"]
            heading_depth = node.attrs["depth"] || 2

            return "" unless title

            HtmlRenderers.build do |doc|
              attrs = { class: "mn-floating-title" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.send(:"h#{heading_depth}", attrs) { doc.text title }
            end
          end
        end
      end
    end
  end
end
