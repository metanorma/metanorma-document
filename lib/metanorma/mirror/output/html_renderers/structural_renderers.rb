# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module StructuralRenderers
          def self.register(registry)
            registry.register_node_handler("doc", instance_method(:render_doc))
            registry.register_node_handler("preface", instance_method(:render_preface))
            registry.register_node_handler("sections", instance_method(:render_sections))
            registry.register_node_handler("bibliography", instance_method(:render_bibliography))
            registry.register_node_handler("footnotes", instance_method(:render_footnotes))
            registry.register_node_handler("soft_break", instance_method(:render_soft_break))
          end

          def render_doc(node, depth: 0)
            HtmlRenderers.build { |doc| HtmlRenderers.embed(doc, render_children(node, depth:)) }
          end

          def render_preface(node, depth: 0)
            HtmlRenderers.build do |doc|
              doc.section(class: "mn-preface") { HtmlRenderers.embed(doc, render_children(node, depth:)) }
            end
          end

          def render_sections(node, depth: 0)
            HtmlRenderers.build do |doc|
              doc.section(class: "mn-sections") { HtmlRenderers.embed(doc, render_children(node, depth:)) }
            end
          end

          def render_bibliography(node, depth: 0)
            HtmlRenderers.build do |doc|
              doc.section(class: "mn-bibliography") { HtmlRenderers.embed(doc, render_children(node, depth:)) }
            end
          end

          def render_footnotes(node, depth: 0)
            HtmlRenderers.build do |doc|
              doc.div(class: "footnotes") do
                doc.ol do
                  node.content.each do |fn|
                    next unless fn.is_a?(Model::Container)

                    fn_attrs = {}
                    fn_attrs[:id] = fn.attrs["id"] if fn.attrs["id"]
                    doc.li(fn_attrs) do
                      HtmlRenderers.embed(doc, render_children(fn))
                      if fn.attrs["ref_id"]
                        doc.a(href: "##{fn.attrs['ref_id']}") { doc.text "↩" }
                      end
                    end
                  end
                end
              end
            end
          end

          def render_soft_break(_node, depth: 0)
            HtmlRenderers.build(&:br)
          end
        end
      end
    end
  end
end
