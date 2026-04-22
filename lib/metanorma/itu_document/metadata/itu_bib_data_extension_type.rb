# frozen_string_literal: true

module Metanorma
  module ItuDocument
    module Metadata
      # Study period element with start/end years.
      class StudyPeriod < Lutaml::Model::Serializable
        attribute :start, :string
        attribute :end_year, :string

        xml do
          element "studyperiod"
          map_element "start", to: :start
          map_element "end", to: :end_year
        end
      end

      # Meeting date with from/to children.
      class MeetingDate < Lutaml::Model::Serializable
        attribute :from, :string
        attribute :to, :string

        xml do
          element "meeting-date"
          map_element "from", to: :from
          map_element "to", to: :to
        end
      end

      # Meeting element with acronym attribute.
      class MeetingElement < Lutaml::Model::Serializable
        attribute :acronym, :string
        attribute :text, :string

        xml do
          element "meeting"
          map_attribute "acronym", to: :acronym
          map_content to: :text
        end
      end

      # Extension point for bibliographical definitions of ITU documents.
      class ItuBibDataExtensionType < Metanorma::IsoDocument::Metadata::IsoBibDataExtensionType
        attribute :structuredidentifier, ItuStructuredIdentifier
        attribute :ip_notice_received, :string
        attribute :studyperiod, StudyPeriod
        attribute :meeting, MeetingElement
        attribute :meeting_date, MeetingDate
        attribute :meeting_place, :string

        xml do
          element "ext"
          map_element "structuredidentifier", to: :structuredidentifier
          map_element "ip-notice-received", to: :ip_notice_received
          map_element "studyperiod", to: :studyperiod
          map_element "meeting", to: :meeting
          map_element "meeting-date", to: :meeting_date
          map_element "meeting-place", to: :meeting_place
        end
      end
    end
  end
end
