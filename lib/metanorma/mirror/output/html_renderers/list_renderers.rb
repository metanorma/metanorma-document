# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module ListRenderers
          def self.register(registry)
            registry.register("bullet_list", :render_bullet_list)
            registry.register("ordered_list", :render_ordered_list)
            registry.register("dl", :render_dl)
            registry.register("list_item", :render_list_item)
            registry.register("dt", :render_dt)
            registry.register("dd", :render_dd)
          end

          def render_bullet_list(node, depth: 0)
            render_list(node, "ul", "mn-bullet-list")
          end

          def render_ordered_list(node, depth: 0)
            render_list(node, "ol", "mn-ordered-list")
          end

          def render_list(node, tag, css_class)
            items = node.content.filter_map do |item|
              next render_node(item) unless item.is_a?(Model::Container) && item.type == "list_item"

              content = render_inline(item.content)
              %(<li class="mn-list-item">#{content}</li>)
            end.join("\n")
            %(<#{tag} class="#{css_class}">\n  #{items}\n</#{tag}>)
          end

          def render_list_item(node, depth: 0)
            content = render_inline(node.content)
            %(<li class="mn-list-item">#{content}</li>)
          end

          def render_dl(node, depth: 0)
            items = node.content.filter_map do |item|
              case item
              when Model::Container, Model::Leaf
                case item.type
                when "dt"
                  %(<dt class="mn-dt">#{render_inline(item.content)}</dt>)
                when "dd"
                  %(<dd class="mn-dd">#{render_children(item)}</dd>)
                else
                  render_node(item)
                end
              end
            end.join("\n")
            %(<dl class="mn-definition-list">\n  #{items}\n</dl>)
          end

          def render_dt(node, depth: 0)
            %(<dt class="mn-dt">#{render_inline(node.content)}</dt>)
          end

          def render_dd(node, depth: 0)
            %(<dd class="mn-dd">#{render_children(node)}</dd>)
          end
        end
      end
    end
  end
end
