# frozen_string_literal: true

require "yaml"

module Metanorma
  module Document
    # Model-layer operations over update units (see
    # Components::UpdateUnits): reading the anchor-keyed amendment
    # register, attaching it to the divisions it names, and deriving the
    # Record of Updates and change queries from the structured records.
    #
    # Traversal dispatches on lutaml attribute declarations only, so it
    # works on any model tree whose divisions declare :update_unit.
    module UpdateUnits
      UpdateUnit = Components::UpdateUnits::UpdateUnit
      AmendmentRecord = Components::UpdateUnits::AmendmentRecord

      # One derived Record of Updates row, in the requested language.
      Row = Struct.new(:sequence, :edition, :date, :approval, :reference,
                       :summary, :affected_units, keyword_init: true)

      class << self
        include Metanorma::Document::ModelAccess

        # Parse an amendment register: a YAML mapping keyed by unit
        # anchor, whose value is either the list of amendment records
        # or a mapping of unit fields (identifier, last_updated,
        # validity, records). Returns { anchor => UpdateUnit }.
        def load_register(yaml)
          data = YAML.safe_load(yaml, permitted_classes: [Date]) || {}
          register_from_hash(data)
        end

        def register_from_hash(data)
          unless data.is_a?(Hash)
            raise ArgumentError, "update register must be keyed by unit anchor"
          end

          data.to_h do |anchor, entry|
            entry = { "records" => entry } if entry.is_a?(Array)
            entry = stringify(entry).merge("unit" => anchor.to_s)
            [anchor.to_s, UpdateUnit.from_yaml(YAML.dump(entry))]
          end
        end

        # Attach register entries to the divisions whose anchor (or id)
        # names them. Returns the anchors that matched no division, so
        # callers can report unresolved records.
        def attach(root, register)
          remaining = register.dup
          each_division(root) do |div|
            key = division_key(div)
            next unless key && remaining.key?(key)

            div.update_unit = remaining.delete(key)
          end
          remaining.keys
        end

        # [division, update_unit] pairs in document order.
        def units(root)
          out = []
          each_division(root) do |div|
            unit = val(div, :update_unit)
            out << [div, unit] if unit
          end
          out
        end

        # The Record of Updates of one unit, derived from its records.
        def record_of_updates(unit, language: nil)
          unit.records.map do |r|
            Row.new(sequence: r.sequence, edition: r.edition, date: r.date,
                    approval: r.approval, reference: r.reference,
                    summary: r.summary_for(language)&.content,
                    affected_units: Array(r.affected_unit))
          end
        end

        # Units amended after the given point (sequence, Date or
        # edition): the change set between a past state and this one.
        def changed_since(root, point)
          units(root).select { |_, unit| unit.changed_since?(point) }
        end

        private

        def division_key(div)
          val(div, :anchor) || val(div, :id)
        end

        def each_division(obj, seen = {}.compare_by_identity, &block)
          return unless serializable?(obj)
          return if seen[obj]

          seen[obj] = true
          yield obj if obj.class.attributes.key?(:update_unit)
          obj.class.attributes.each_key do |name|
            next if name == :update_unit

            Array(obj.public_send(name)).each do |child|
              each_division(child, seen, &block)
            end
          end
        end

        def stringify(value)
          case value
          when Hash then value.to_h { |k, v| [k.to_s, stringify(v)] }
          when Array then value.map { |v| stringify(v) }
          else value
          end
        end
      end
    end
  end
end
