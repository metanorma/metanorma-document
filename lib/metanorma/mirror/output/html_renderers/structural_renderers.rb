# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module StructuralRenderers
          def self.register(registry)
            registry.register("doc", :render_doc)
            registry.register("preface", :render_preface)
            registry.register("sections", :render_sections)
            registry.register("bibliography", :render_bibliography)
            registry.register("footnotes", :render_footnotes)
            registry.register("soft_break", :render_soft_break)
          end

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

          def render_footnotes(node, depth: 0)
            items = node.content.filter_map do |fn|
              id = fn.attrs["id"]
              ref_id = fn.attrs["ref_id"]
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
        end
      end
    end
  end
end
