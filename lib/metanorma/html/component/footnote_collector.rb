# frozen_string_literal: true

module Metanorma
  module Html
    module Component
      # Collects footnote content encountered during rendering.
      # Deduplicates by reference letter/number so each footnote definition
      # appears once, even when referenced from multiple locations.
      class FootnoteCollector
        def initialize
          @footnotes = []
          @ref_map = {}
          @id_map = {}
        end

        # Register a footnote and return its sequential number.
        # Deduplicates by reference: same reference = same footnote number.
        def register(fn)
          fn_id = fn.id || fn.reference.to_s
          ref = fn.reference.to_s

          # If we've seen this reference before, reuse its number
          if @ref_map.key?(ref)
            return @ref_map[ref]
          end

          number = @footnotes.size + 1
          @ref_map[ref] = number
          @id_map[fn_id] = number
          @footnotes << FootnoteEntry.new(
            id: fn_id,
            number: number,
            reference: ref,
            content: fn.p,
            fmt_label: fn.fmt_fn_label
          )
          number
        end

        def empty?
          @footnotes.empty?
        end

        def each(&blk)
          @footnotes.each(&blk)
        end

        def to_a
          @footnotes
        end
      end

      FootnoteEntry = Struct.new(:id, :number, :reference, :content, :fmt_label,
                                 keyword_init: true)
    end
  end
end
