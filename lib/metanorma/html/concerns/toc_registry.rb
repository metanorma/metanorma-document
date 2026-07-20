# frozen_string_literal: true

module Metanorma
  module Html
    module Concerns
      # Table-of-contents entry collection and ToC rendering, mixed into
      # BaseRenderer. Sub-renderers register section/figure/table entries
      # as they walk the document; assemble_document renders the collected
      # entries through the _toc.html.liquid template.
      module TocRegistry
        def toc_entries
          @toc_entries
        end

        def build_toc_html(entries)
          entry_drops = entries.map { |e| Drops::TocEntryDrop.new(e) }
          figure_drops = @figure_entries.map { |f| Drops::FigureListEntryDrop.new(f) }
          table_drops = @table_entries.map { |t| Drops::FigureListEntryDrop.new(t) }
          has_special_lists = !@figure_entries.empty? || !@table_entries.empty?

          render_liquid("_toc.html.liquid", {
                          "entries" => entry_drops,
                          "figures" => figure_drops,
                          "tables" => table_drops,
                          "has_special_lists" => has_special_lists,
                        })
        end

        def register_toc_entry(id:, level:, text:)
          @toc_entries << { id: id, level: level, text: text }
        end

        def register_figure_entry(id:, text:)
          @figure_entries << { id: id, text: text }
        end

        def figure_entries
          @figure_entries
        end

        def register_table_entry(id:, text:)
          @table_entries << { id: id, text: text }
        end
      end
    end
  end
end
