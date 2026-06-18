# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module ListRenderers
          def self.register(registry)
            registry.register_node_handler("bullet_list",
                                           instance_method(:render_bullet_list))
            registry.register_node_handler("ordered_list",
                                           instance_method(:render_ordered_list))
            registry.register_node_handler("dl", instance_method(:render_dl))
            registry.register_node_handler("list_item",
                                           instance_method(:render_list_item))
            registry.register_node_handler("dt", instance_method(:render_dt))
            registry.register_node_handler("dd", instance_method(:render_dd))
          end

          def render_bullet_list(node, depth: 0)
            render_list(node, "ul", "mn-bullet-list")
          end

          def render_ordered_list(node, depth: 0)
            render_list(node, "ol", "mn-ordered-list")
          end

          def render_list_item(node, depth: 0)
            HtmlRenderers.build do |doc|
              doc.li(class: "mn-list-item") do
                HtmlRenderers.embed(doc, render_inline(node.content))
              end
            end
          end

          def render_dl(node, depth: 0)
            HtmlRenderers.build do |doc|
              doc.dl(class: "mn-definition-list") do
                node.content.each do |item|
                  next unless item.is_a?(Model::Container) || item.is_a?(Model::Leaf)

                  case item.type
                  when "dt"
                    doc.dt(class: "mn-dt") do
                      HtmlRenderers.embed(doc, render_inline(item.content))
                    end
                  when "dd"
                    doc.dd(class: "mn-dd") do
                      HtmlRenderers.embed(doc, render_children(item))
                    end
                  else
                    HtmlRenderers.embed(doc, render_node(item))
                  end
                end
              end
            end
          end

          def render_dt(node, depth: 0)
            HtmlRenderers.build do |doc|
              doc.dt(class: "mn-dt") do
                HtmlRenderers.embed(doc, render_inline(node.content))
              end
            end
          end

          def render_dd(node, depth: 0)
            HtmlRenderers.build do |doc|
              doc.dd(class: "mn-dd") do
                HtmlRenderers.embed(doc, render_children(node))
              end
            end
          end

          private

          def render_list(node, tag, css_class)
            HtmlRenderers.build do |doc|
              doc.public_send(tag, class: css_class) do
                node.content.each do |item|
                  if item.is_a?(Model::Container) && item.type == "list_item"
                    doc.li(class: "mn-list-item") do
                      HtmlRenderers.embed(doc, render_inline(item.content))
                    end
                  else
                    HtmlRenderers.embed(doc, render_node(item))
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
