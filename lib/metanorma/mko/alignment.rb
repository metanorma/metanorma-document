# frozen_string_literal: true

require "json"

module Metanorma
  module Mko
    # Interlingual alignment (MN 116 §stability, P2): units across
    # language editions of the same document are the same knowledge
    # object when their anchors match — Metanorma translations carry
    # the semantic anchors. Emits variant_of unit edges binding the
    # editions: parallel corpora, cross-language retrieval with
    # source-language provenance, and consistency diffs between
    # translations.
    module Alignment
      class << self
        # Align two bundles of the same document (different language
        # editions) by stable unit anchor. Returns [Schema::Edge] with
        # kind variant_of; content-hash anchors (h-…) and unmatched
        # units are simply not aligned — never guessed.
        def align(bundle_a, bundle_b)
          a = units_by_anchor(bundle_a)
          b = units_by_anchor(bundle_b)
          a.keys.intersection(b.keys).filter_map do |anchor|
            next if anchor.to_s.empty? || anchor.start_with?("h-")

            Schema::Edge.new(from: a[anchor], to: b[anchor],
                              kind: "variant_of")
          end
        end

        # Write alignment.jsonl into bundle_a's directory; returns the
        # path. The alignment is a derived artifact — regeneration
        # replaces it.
        def export(bundle_a, bundle_b)
          edges = align(bundle_a, bundle_b)
          path = File.join(bundle_a, "alignment.jsonl")
          File.write(path, edges.map(&:to_json).join("\n") + "\n")
          path
        end

        private

        def units_by_anchor(bundle)
          file = File.join(bundle, "units.jsonl")
          File.readlines(file).each_with_object({}) do |line, h|
            unit = JSON.parse(line)
            h[unit["anchor"]] = unit["id"]
          end
        end
      end
    end
  end
end
