# frozen_string_literal: true

require "base64"

module Metanorma
  module Html
    module Renderers
      class BlockRenderer
        BLOCK_CHILDREN = {
          paragraphs: :render_paragraph,
          ul: :render_unordered_list,
          ol: :render_ordered_list,
          dl: :render_definition_list,
          sourcecode: :render_sourcecode,
          table: :render_table,
          figure: :render_figure,
          quote: :render_quote,
          formula: :render_formula,
        }.freeze

        SIMPLE_CHILDREN = {
          paragraphs: :render_paragraph,
        }.freeze

        NOTE_CHILDREN = {
          paragraphs: :render_paragraph,
          ul: :render_unordered_list,
          ol: :render_ordered_list,
          dl: :render_definition_list,
          quote: :render_quote,
        }.freeze

        def initialize(coordinator)
          @coordinator = coordinator
        end

        def render_paragraph(p, **_opts)
          attrs = element_attrs(id: safe_attr(p, :id),
                                style: coordinator.alignment_style(safe_attr(p,
                                                                             :alignment)))
          content = coordinator.render_mixed_inline(p)
          render_liquid("_paragraph.html.liquid", {
                          "attrs" => attrs,
                          "content" => content,
                        })
        end

        def render_table(table, **_opts)
          attrs = element_attrs(id: safe_attr(table, :id), class: "table-block")
          table_id = safe_attr(table, :id)
          name_el = safe_attr(table, :fmt_name) || safe_attr(table, :name)
          if table_id && name_el
            register_table_entry(id: table_id,
                                 text: coordinator.extract_plain_text(name_el))
          end
          col_count = table_column_count(table)

          caption_html = if name_el
                           coordinator.render_inline_element(name_el)
                         end

          colgroup_html = if table.colgroup
                            render_table_colgroup(table.colgroup)
                          end

          thead_html = if table.thead
                         render_table_section(table.thead, "thead")
                       end

          tbody_html = if table.tbody
                         render_table_section(table.tbody, "tbody")
                       end

          tfoot_html = nil
          if table.tfoot || (table.note && !table.note.empty?)
            tfoot_inner = render_table_section_rows(table.tfoot) if table.tfoot
            notes_html = nil
            if table.note && !table.note.empty?
              notes_inner = table.note.filter_map { |n| render_note(n) }.join
              notes_html = render_liquid("_element.html.liquid", "tag" => "tr", "extra_attrs" => "",
                                                                 "content" => render_liquid("_element.html.liquid", "tag" => "td", "extra_attrs" => %( colspan="#{col_count}" class="table-notes"), "content" => notes_inner))
            end
            tfoot_html = render_liquid("_element.html.liquid", "tag" => "tfoot", "extra_attrs" => "",
                                                               "content" => "#{tfoot_inner}#{notes_html}")
          end

          render_liquid("_table.html.liquid", {
                          "attrs" => attrs,
                          "caption" => caption_html,
                          "colgroup_html" => colgroup_html,
                          "thead_html" => thead_html,
                          "tbody_html" => tbody_html,
                          "tfoot_html" => tfoot_html,
                        })
        end

        def table_column_count(table)
          if table.colgroup&.col && !table.colgroup.col.empty?
            return table.colgroup.col.size
          end

          max_cols = 0
          %i[thead tbody tfoot].each do |section|
            sec = table.public_send(section)
            next unless sec&.tr

            sec.tr.each do |tr|
              cols = 0
              Array(tr.th).each do |th|
                cols += th.colspan && th.colspan > 1 ? th.colspan : 1
              end
              Array(tr.td).each do |td|
                cols += td.colspan && td.colspan > 1 ? td.colspan : 1
              end
              max_cols = cols if cols > max_cols
            end
          end
          max_cols.positive? ? max_cols : 1
        end

        def render_table_colgroup(colgroup)
          colgroup.col&.filter_map do |col|
            attrs = element_attrs(style: col.width ? "width: #{col.width}" : nil)
            render_liquid("_element.html.liquid", "tag" => "col",
                                                  "extra_attrs" => attrs, "content" => "")
          end&.join
        end

        def render_table_section(section, tag_name)
          inner = render_table_section_rows(section)
          render_liquid("_element.html.liquid", "tag" => tag_name,
                                                "extra_attrs" => "", "content" => inner)
        end

        def render_table_section_rows(section)
          section.tr&.filter_map do |tr|
            inner_parts = []
            walked = coordinator.walk_ordered(tr) do |type, obj|
              next unless type == :element

              inner_parts << (render_table_cell(obj) || "")
            end
            unless walked
              Array(tr.th).each do |th|
                inner_parts << (render_table_cell(th, "th") || "")
              end
              Array(tr.td).each do |td|
                inner_parts << (render_table_cell(td, "td") || "")
              end
            end
            render_liquid("_element.html.liquid", "tag" => "tr",
                                                  "extra_attrs" => "", "content" => inner_parts.join)
          end&.join
        end

        def render_unordered_list(ul, **_opts)
          attrs = element_attrs(id: safe_attr(ul, :id))
          items = ul.listitem&.filter_map do |li|
            render_list_item_content(li)
          end || []
          render_liquid("_list.html.liquid", {
                          "list_tag" => "ul",
                          "attrs" => attrs,
                          "items" => items,
                        })
        end

        def render_table_cell(cell, force_tag = nil)
          tag_name = force_tag || (cell.is_a?(Metanorma::Document::Components::Tables::HeaderTableCell) ? "th" : "td")
          attrs = element_attrs(
            colspan: safe_attr(cell, :colspan),
            rowspan: safe_attr(cell, :rowspan),
            align: safe_attr(cell, :alignment),
            valign: safe_attr(cell, :vertical_alignment),
          )
          content = coordinator.render_cell_content(cell)
          render_liquid("_element.html.liquid", {
                          "tag" => tag_name,
                          "extra_attrs" => attrs,
                          "content" => content,
                        })
        end

        def render_ordered_list(ol, **_opts)
          attrs = element_attrs(id: safe_attr(ol, :id),
                                start: safe_attr(ol, :start), type: safe_attr(ol, :type_attr))
          items = ol.listitem&.filter_map do |li|
            render_list_item_content(li)
          end || []
          render_liquid("_list.html.liquid", {
                          "list_tag" => "ol",
                          "attrs" => attrs,
                          "items" => items,
                        })
        end

        def render_list_item_content(li)
          li_id = safe_attr(li, :id)
          attrs = li_id ? %( id="#{escape_html(li_id)}") : ""
          inner = coordinator.render_mixed_content_in_order(li)
          render_liquid("_list_item.html.liquid", "attrs" => attrs,
                                                  "content" => inner)
        end

        def render_definition_list(dl, **_opts)
          attrs = element_attrs(id: safe_attr(dl, :id))
          terms = dl.dt&.each_with_index&.map do |dt, i|
            dt_html = coordinator.render_mixed_inline(dt)
            dd = dl.dd&.[](i)
            dd_html = dd ? coordinator.render_mixed_inline(dd) : nil
            { "dt" => dt_html, "dd" => dd_html }
          end || []
          render_liquid("_definition_list.html.liquid", {
                          "attrs" => attrs,
                          "terms" => terms,
                        })
        end

        def render_figure(figure, **_opts)
          drop = Drops::FigureDrop.from_model(figure,
                                              renderer: coordinator.renderer_context)
          render_liquid("_figure.html.liquid", { "block" => drop })
        end

        def render_image(image)
          src_val = image_source(image)
          attrs = element_attrs(
            id: safe_attr(image, :id),
            src: src_val,
            alt: safe_attr(image, :alt),
            height: safe_attr(image, :height),
            width: safe_attr(image, :width),
          )
          render_liquid("_image.html.liquid", { "attrs" => attrs })
        end

        def image_source(image)
          svg_xml = safe_attr(image, :inline_svg)
          if svg_xml && !svg_xml.empty?
            "data:image/svg+xml;base64,#{Base64.strict_encode64(svg_xml)}"
          else
            safe_attr(image, :source)
          end
        end

        def render_video(video)
          attrs = element_attrs(
            id: safe_attr(video, :id),
            src: safe_attr(video, :src),
          )
          render_liquid("_video.html.liquid", { "attrs" => attrs })
        end

        def render_audio(audio)
          attrs = element_attrs(
            id: safe_attr(audio, :id),
            src: safe_attr(audio, :src),
          )
          render_liquid("_audio.html.liquid", { "attrs" => attrs })
        end

        def render_note(note, **_opts)
          drop = Drops::NoteDrop.from_model(note,
                                            renderer: coordinator.renderer_context)
          render_liquid("_note.html.liquid", { "block" => drop })
        end

        def render_example(example, **_opts)
          drop = Drops::ExampleDrop.from_model(example,
                                               renderer: coordinator.renderer_context)
          render_liquid("_example.html.liquid", { "block" => drop })
        end

        def render_form(form, **_opts)
          attrs = element_attrs(id: safe_attr(form, :id), class: "form")
          content = coordinator.render_ordered_content(form)
          render_liquid("_element.html.liquid", {
                          "tag" => "div",
                          "extra_attrs" => attrs,
                          "content" => content,
                        })
        end

        def render_sourcecode(sc, **_opts)
          drop = Drops::SourcecodeDrop.from_model(sc,
                                                  renderer: coordinator.renderer_context)
          render_liquid("_sourcecode.html.liquid", { "block" => drop })
        end

        def render_formula(formula, **_opts)
          drop = Drops::FormulaDrop.from_model(formula,
                                               renderer: coordinator.renderer_context)
          render_liquid("_formula.html.liquid", { "block" => drop })
        end

        def render_quote(quote, **_opts)
          attrs = element_attrs(id: safe_attr(quote, :id), class: "quote")
          content_parts = []
          quote.paragraphs&.each do |para|
            content_parts << (render_paragraph(para) || "")
          end
          quote.ul&.each do |ul|
            content_parts << (render_unordered_list(ul) || "")
          end
          quote.ol&.each do |ol|
            content_parts << (render_ordered_list(ol) || "")
          end
          content = content_parts.join
          attribution_html = if quote.attribution
                               coordinator.render_mixed_inline(quote.attribution)
                             end
          render_liquid("_quote.html.liquid", {
                          "attrs" => attrs,
                          "content" => content,
                          "attribution" => attribution_html,
                        })
        end

        def render_admonition(admonition, **_opts)
          drop = Drops::AdmonitionDrop.from_model(admonition,
                                                  renderer: coordinator.renderer_context)
          render_liquid("_admonition.html.liquid", { "block" => drop })
        end

        def render_bookmark(bookmark, **_opts)
          render_liquid("_bookmark.html.liquid", {
                          "id" => escape_html(safe_attr(bookmark, :id).to_s),
                        })
        end

        def render_block_children(model, children:)
          parts = []
          children.each do |attr, render_method|
            values = safe_attr(model, attr)
            next if values.nil?

            Array(values).each do |v|
              parts << (public_send(render_method, v) || "")
            end
          end
          parts.join
        end

        def render_note_children(model)
          render_block_children(model, children: NOTE_CHILDREN)
        end

        def render_simple_children(model)
          render_block_children(model, children: SIMPLE_CHILDREN)
        end

        def render_full_block_children(model)
          render_block_children(model, children: BLOCK_CHILDREN)
        end

        private

        attr_reader :coordinator

        def safe_attr(obj, method_name)
          coordinator.safe_attr(obj, method_name)
        end

        def escape_html(text)
          coordinator.escape_html(text)
        end

        def element_attrs(**attrs)
          coordinator.element_attrs(**attrs)
        end

        def render_liquid(template_name, assigns)
          coordinator.render_liquid(template_name, assigns)
        end

        def register_table_entry(id:, text:)
          coordinator.register_table_entry(id: id, text: text)
        end
      end
    end
  end
end
