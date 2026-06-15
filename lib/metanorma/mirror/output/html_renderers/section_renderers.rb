# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module SectionRenderers
          def self.register(registry)
            registry.register("clause", :render_clause)
            registry.register("annex", :render_annex)
            registry.register("content_section", :render_content_section)
            registry.register("abstract", :render_content_section)
            registry.register("foreword", :render_content_section)
            registry.register("introduction", :render_content_section)
            registry.register("acknowledgements", :render_content_section)
            registry.register("terms", :render_terms)
            registry.register("definitions", :render_definitions)
            registry.register("references", :render_references)
            registry.register("floating_title", :render_floating_title)
          end

          def render_clause(node, depth: 0)
            id_attr = build_id_attr(node)
            title = node.attrs["title"]
            number = node.attrs["number"] || @numbering[node.attrs["id"]]
            prefix = number ? "#{e(number)} " : ""
            heading = title ? %(<h#{depth + 2}#{id_attr} class="mn-clause__title">#{prefix}#{e(title)}</h#{depth + 2}>) : ""

            content = render_children(node, depth: depth + 1)

            %(<section#{id_attr} class="mn-clause">\n  #{heading}\n  #{content}\n</section>)
          end

          def render_annex(node, depth: 0)
            id_attr = build_id_attr(node)
            title = node.attrs["title"]
            heading = title ? %(<h2#{id_attr} class="mn-annex__title">#{e(title)}</h2>) : ""

            content = render_children(node, depth: depth + 1)

            %(<section#{id_attr} class="mn-annex">\n  #{heading}\n  #{content}\n</section>)
          end

          def render_content_section(node, depth: 0)
            id_attr = build_id_attr(node)
            title = node.attrs["title"]
            css_class = "mn-#{node.type}"
            heading = title ? %(<h2#{id_attr} class="#{css_class}__title">#{e(title)}</h2>) : ""
            content = render_children(node, depth:)
            %(<section#{id_attr} class="#{css_class}">\n  #{heading}\n  #{content}\n</section>)
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
            id_attr = build_id_attr(node)
            title = node.attrs["title"]
            heading_depth = node.attrs["depth"] || 2
            title ? %(<h#{heading_depth}#{id_attr} class="mn-floating-title">#{e(title)}</h#{heading_depth}>) : ""
          end
        end
      end
    end
  end
end
