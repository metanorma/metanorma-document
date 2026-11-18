# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module UpdateUnits
        # One amendment of an update unit: its place in the unit's
        # amendment sequence, the publication edition it was issued in,
        # its date, the approval that authorised it, the reference that
        # announced it (e.g. a circular letter), a localized summary,
        # and any other units it affected.
        class AmendmentRecord < Lutaml::Model::Serializable
          attribute :sequence, :integer
          attribute :edition, :string
          attribute :date, :date
          attribute :approval, :string
          attribute :reference, :string
          attribute :summary, Summary, collection: true
          attribute :affected_unit, :string, collection: true

          xml do
            element "amendment-record"
            map_attribute "sequence", to: :sequence
            map_element "edition", to: :edition
            map_element "date", to: :date
            map_element "approval", to: :approval
            map_element "reference", to: :reference
            map_element "summary", to: :summary
            map_element "affected-unit", to: :affected_unit
          end

          key_value do
            map "sequence", to: :sequence
            map "edition", to: :edition
            map "date", to: :date
            map "approval", to: :approval
            map "reference", to: :reference
            map "summary", to: :summary
            map "affected_units", to: :affected_unit
          end

          # The summary in the requested language, falling back to the
          # first summary when that language has none.
          def summary_for(language)
            list = Array(summary)
            list.find { |s| s.language == language } || list.first
          end
        end
      end
    end
  end
end
