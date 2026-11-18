# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module UpdateUnits
        # The update-unit declaration of a division: its unit name (the
        # anchor-style key the records are filed under, e.g. "B-400"),
        # its bibliographic identifier (e.g. "S-4 Part B, Section 400";
        # built by the flavor's identifier grammar, held here as text),
        # last-update date, validity period, and amendment records.
        class UpdateUnit < Lutaml::Model::Serializable
          attribute :unit, :string
          attribute :identifier, :string
          attribute :last_updated, :date
          attribute :validity, Validity
          attribute :amendment_record, AmendmentRecord, collection: true

          xml do
            element "update-unit"
            map_attribute "unit", to: :unit
            map_element "identifier", to: :identifier
            map_element "last-updated", to: :last_updated
            map_element "validity", to: :validity
            map_element "amendment-record", to: :amendment_record
          end

          key_value do
            map "unit", to: :unit
            map "identifier", to: :identifier
            map "last_updated", to: :last_updated
            map "validity", to: :validity
            map "records", to: :amendment_record
          end

          # Records in amendment order: by sequence, then date; records
          # without either keep their authored order.
          def records
            Array(amendment_record).each_with_index.sort_by do |r, i|
              [r.sequence || Float::INFINITY, r.date || Date.new(9999), i]
            end.map(&:first)
          end

          # The declared last-update date, else the latest record date.
          def last_updated_on
            last_updated || records.filter_map(&:date).max
          end

          # Records issued after the given point: a record sequence
          # (Integer), a Date, or an edition string compared as a
          # dotted version ("4.9.0" < "4.10.0").
          def records_since(point)
            records.select { |r| after?(r, point) }
          end

          def changed_since?(point)
            !records_since(point).empty?
          end

          private

          def after?(record, point)
            case point
            when Integer then record.sequence && record.sequence > point
            when Date then record.date && record.date > point
            else edition_after?(record.edition, point.to_s)
            end
          end

          def edition_after?(edition, point)
            return false unless edition
            unless Gem::Version.correct?(edition) && Gem::Version.correct?(point)
              return false
            end

            Gem::Version.new(edition) > Gem::Version.new(point)
          end
        end
      end
    end
  end
end
