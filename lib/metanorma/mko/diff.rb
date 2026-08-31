# frozen_string_literal: true

require "json"

module Metanorma
  module Mko
    # Structured edition diffs (MN 116 §diffs; issue #53 item 5):
    # "what changed between the 2000 and the 2017 edition" becomes a
    # machine answer, not an expert reading marathon. Built on the
    # stable-id contract — units pair by anchor, content hashes say
    # whether anything changed — so a diff is exact and incremental.
    module Diff
      class << self
        # Two bundles of the same document (different editions).
        # Returns a change set:
        #   { from:, to:, added: [unit summaries], removed: [...],
        #     changed: [{ anchor, type, number, fields: [...] }] }
        # fields carries field-level detail (text, title, number, and
        # typed payload fields: designations, definition, rows,
        # statement, …).
        def between(bundle_a, bundle_b)
          a = units_by_anchor(bundle_a)
          b = units_by_anchor(bundle_b)
          {
            "from" => document_id(bundle_a),
            "to" => document_id(bundle_b),
            "added" => (b.keys - a.keys).map { |k| summary(b[k]) },
            "removed" => (a.keys - b.keys).map { |k| summary(a[k]) },
            "changed" => (a.keys & b.keys).filter_map do |k|
              next if a[k]["hash"] == b[k]["hash"]

              changed_unit(a[k], b[k])
            end,
          }
        end

        # Write <dir>/<from>-to-<to>.diff.json; returns the path.
        def export(bundle_a, bundle_b, to:)
          diff = between(bundle_a, bundle_b)
          name = "#{Mko.slug(diff["from"])}-to-#{Mko.slug(diff["to"])}.diff.json"
          path = File.join(to, name)
          File.write(path, JSON.pretty_generate(diff) + "\n")
          path
        end

        private

        def units_by_anchor(bundle)
          File.readlines(File.join(bundle, "units.jsonl"))
              .each_with_object({}) do |line, h|
            unit = JSON.parse(line)
            h[unit["anchor"]] = unit
          end
        end

        def document_id(bundle)
          JSON.parse(File.read(File.join(bundle, "document.json")))
              .dig("ids", "canonical")
        end

        def summary(unit)
          { "anchor" => unit["anchor"], "type" => unit["type"],
            "number" => unit["number"], "title" => unit["title"] }
        end

        # Field-level detail: top-level fields first, then the payload
        # sub-fields consumers act on (terminology changes, table row
        # deltas, requirement restatements).
        def changed_unit(old, new)
          fields = %w[text title number obligation].select do |f|
            old[f] != new[f]
          end
          fields.concat(payload_changes(old, new))
          summary(new).merge("fields" => fields.uniq)
        end

        def payload_changes(old, new)
          op = old["payload"] || {}
          np = new["payload"] || {}
          return [] if op == np

          changed = []
          %w[designations admitted deprecated definition statement
             subject identifier klass caption columns].each do |f|
            changed << f if op[f] != np[f]
          end
          if op["rows"] != np["rows"]
            changed << "rows" \
              "(+#{(np["rows"] || []).size - (op["rows"] || []).size})"
          end
          changed << "payload" if changed.empty? && op != np
          changed
        end
      end
    end
  end
end
