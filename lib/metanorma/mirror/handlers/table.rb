# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Table
        def self.call(element, context:)
          attrs = table_attrs(element)
          content = []

          thead = SafeAttr.read(element, :thead)
          if thead
            rows = extract_rows(thead, context:)
            unless rows.empty?
              content << Handlers.build_node("table_head",
                                             content: rows)
            end
          end

          tbody = SafeAttr.read(element, :tbody)
          if tbody
            rows = extract_rows(tbody, context:)
            unless rows.empty?
              content << Handlers.build_node("table_body",
                                             content: rows)
            end
          end

          tfoot = SafeAttr.read(element, :tfoot)
          if tfoot
            rows = extract_rows(tfoot, context:)
            unless rows.empty?
              content << Handlers.build_node("table_foot",
                                             content: rows)
            end
          end

          Handlers.build_node("table", attrs: attrs, content: content)
        end

        def self.extract_rows(table_section, context:)
          Array(table_section.tr).map do |tr|
            cells = Array(tr.td).map { |td| build_cell(td, context:) }
            Array(tr.th).each { |th| cells << build_cell(th, context:) }

            row_attrs = {}
            row_attrs[:id] = SafeAttr.read(tr, :id)
            Handlers.build_node("table_row", attrs: row_attrs.compact,
                                             content: cells)
          end
        end

        def self.build_cell(cell, context:)
          attrs = {}
          attrs[:colspan] = SafeAttr.read(cell, :colspan)
          attrs[:rowspan] = SafeAttr.read(cell, :rowspan)
          attrs[:align] = SafeAttr.read(cell, :align)
          attrs[:valign] = SafeAttr.read(cell, :valign)

          content = Inline.extract_inline(cell, context:)

          Handlers.build_node("table_cell", attrs: attrs.compact,
                                            content: content)
        end

        def self.table_attrs(element)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:width] = SafeAttr.read(element, :width)
          attrs[:align] = SafeAttr.read(element, :align)
          attrs[:unnumbered] = SafeAttr.read(element, :unnumbered)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          name = SafeAttr.read(element, :name)
          attrs[:title] = Handlers.extract_name_text(name) if name
          attrs.compact
        end
      end
    end
  end
end
