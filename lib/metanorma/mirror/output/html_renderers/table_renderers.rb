# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module TableRenderers
          def self.register(registry)
            registry.register("table", :render_table)
            registry.register("table_head", :render_table_section)
            registry.register("table_body", :render_table_section)
            registry.register("table_foot", :render_table_section)
          end

          def render_table(node, depth: 0)
            id_attr = build_id_attr(node)
            title = node.attrs["title"]
            header = title ? %(<div class="mn-table__header">#{e(title)}</div>) : ""

            content = node.content
            thead = render_table_sections(content.select { |s| s.is_a?(Model::Container) && s.type == "table_head" }, "th")
            tbody = render_table_sections(content.select { |s| s.is_a?(Model::Container) && s.type == "table_body" }, "td")
            tfoot = render_table_sections(content.select { |s| s.is_a?(Model::Container) && s.type == "table_foot" }, "td")

            %(<div#{id_attr} class="mn-table">#{header}\n  <table>\n#{thead}#{tbody}#{tfoot}\n  </table>\n</div>)
          end

          def render_table_section(node, depth: 0)
            wrapper_tag = case node.type
                          when "table_head" then "thead"
                          when "table_foot" then "tfoot"
                          else "tbody"
                          end
            cell_tag = wrapper_tag == "thead" ? "th" : "td"

            rows = node.content.filter_map do |row|
              next unless row.is_a?(Model::Container) && row.type == "table_row"

              cells = row.content.filter_map do |cell|
                next unless cell.is_a?(Model::Container)

                cell_attrs = cell.attrs
                colspan = cell_attrs["colspan"] ? %( colspan="#{cell_attrs['colspan']}") : ""
                rowspan = cell_attrs["rowspan"] ? %( rowspan="#{cell_attrs['rowspan']}") : ""
                content = render_inline(cell.content)
                %(<#{cell_tag}#{colspan}#{rowspan}>#{content}</#{cell_tag}>)
              end.join
              %(<tr>#{cells}</tr>)
            end.join("\n")
            %(    <#{wrapper_tag}>\n      #{rows}\n    </#{wrapper_tag}>\n)
          end

          private

          def render_table_sections(sections, cell_tag)
            sections.map { |s| render_table_section_content(s, cell_tag) }.join
          end

          def render_table_section_content(section, cell_tag)
            rows = section.content.filter_map do |row|
              next unless row.is_a?(Model::Container) && row.type == "table_row"

              cells = row.content.filter_map do |cell|
                next unless cell.is_a?(Model::Container)

                cell_attrs = cell.attrs
                colspan = cell_attrs["colspan"] ? %( colspan="#{cell_attrs['colspan']}") : ""
                rowspan = cell_attrs["rowspan"] ? %( rowspan="#{cell_attrs['rowspan']}") : ""
                content = render_inline(cell.content)
                %(<#{cell_tag}#{colspan}#{rowspan}>#{content}</#{cell_tag}>)
              end.join
              %(<tr>#{cells}</tr>)
            end.join("\n")
            wrapper_tag = case section.type
                          when "table_head" then "thead"
                          when "table_foot" then "tfoot"
                          else "tbody"
                          end
            %(    <#{wrapper_tag}>\n      #{rows}\n    </#{wrapper_tag}>\n)
          end
        end
      end
    end
  end
end
