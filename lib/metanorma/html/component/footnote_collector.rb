# frozen_string_literal: true

module Metanorma
  module Html
    module Component
      # Collects footnote content encountered during rendering.
      # Deduplicates by footnote definition (target id, falling back to the
      # fn id/reference) so each definition appears once, even when several
      # <fn> references with differing reference attrs point at it.
      class FootnoteCollector
        def initialize
          @footnotes = []
          @entries_by_key = {}
        end

        # Register a footnote and return its FootnoteEntry.
        # +label_text+ is the fn's presentation autonum label; the first
        # registration's label wins.
        def register(fn, label_text: nil)
          fn_id = fn.id || fn.reference.to_s
          key = fn.respond_to?(:target) && fn.target && !fn.target.empty? ? fn.target : fn_id

          if (seen = @entries_by_key[key])
            seen.fmt_label ||= label_text
            return seen
          end

          entry = FootnoteEntry.new(
            id: fn_id,
            number: @footnotes.size + 1,
            reference: fn.reference.to_s,
            content: fn.p,
            fmt_label: label_text,
            source_fn: fn,
          )
          @footnotes << entry
          @entries_by_key[key] = entry
          entry
        end

        def empty?
          @footnotes.empty?
        end

        def each(&)
          @footnotes.each(&)
        end

        def to_a
          @footnotes
        end
      end

      FootnoteEntry = Struct.new(:id, :number, :reference, :content, :fmt_label,
                                 :source_fn, keyword_init: true)
    end
  end
end
