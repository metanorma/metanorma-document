# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module TableRenderers
          WRAPPER_TAGS = {
            "table_head" => "thead",
            "table_foot" => "tfoot",
            "table_body" => "tbody",
          }.freeze

          def self.register(registry)
            registry.register_node_handler("table", instance_method(:render_table))
            registry.register_node_handler("table_head", instance_method(:render_table_section))
            registry.register_node_handler("table_body", instance_method(:render_table_section))
            registry.register_node_handler("table_foot", instance_method(:render_table_section))
          end

          def render_table(node, depth: 0)
            sections = node.content.grep(Model::Container)

            HtmlRenderers.build do |doc|
              attrs = { class: "mn-table" }
              attrs[:id] = node.attrs["id"] if node.attrs["id"]
              doc.div(attrs) do
                if node.attrs["title"]
                  doc.div(class: "mn-table__header") { doc.text node.attrs["title"] }
                end
                doc.table do
                  sections.each { |section| HtmlRenderers.embed(doc, build_table_section(section)) }
                end
              end
            end
          end

          def render_table_section(node, depth: 0)
            build_table_section(node)
          end

          private

          def build_table_section(section)
            wrapper_tag = WRAPPER_TAGS[section.type] || "tbody"
            cell_tag = wrapper_tag == "thead" ? "th" : "td"

            HtmlRenderers.build do |doc|
              doc.public_send(wrapper_tag) do
                section.content.each do |row|
                  next unless row.is_a?(Model::Container) && row.type == "table_row"

                  doc.tr do
                    row.content.each do |cell|
                      next unless cell.is_a?(Model::Container)

                      HtmlRenderers.embed(doc, build_table_cell(cell, cell_tag))
                    end
                  end
                end
              end
            end
          end

          def build_table_cell(cell, cell_tag)
            HtmlRenderers.build do |doc|
              attrs = {}
              attrs[:colspan] = cell.attrs["colspan"] if cell.attrs["colspan"]
              attrs[:rowspan] = cell.attrs["rowspan"] if cell.attrs["rowspan"]
              doc.public_send(cell_tag, attrs) do
                HtmlRenderers.embed(doc, render_inline(cell.content))
              end
            end
          end
        end
      end
    end
  end
end
