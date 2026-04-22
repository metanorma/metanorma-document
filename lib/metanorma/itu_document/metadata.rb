# frozen_string_literal: true

module Metanorma
  module ItuDocument
    module Metadata
      autoload :ItuBibDataExtensionType,
               "#{__dir__}/metadata/itu_bib_data_extension_type"
      autoload :ItuBibliographicItem,
               "#{__dir__}/metadata/itu_bibliographic_item"
      autoload :ItuSeries, "#{__dir__}/metadata/itu_series"
      autoload :ItuStructuredIdentifier,
               "#{__dir__}/metadata/itu_structured_identifier"
      autoload :StudyPeriod, "#{__dir__}/metadata/itu_bib_data_extension_type"
      autoload :MeetingDate, "#{__dir__}/metadata/itu_bib_data_extension_type"
      autoload :MeetingElement,
               "#{__dir__}/metadata/itu_bib_data_extension_type"
    end
  end
end
