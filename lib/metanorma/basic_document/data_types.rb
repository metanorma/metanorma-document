# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module DataTypes
      autoload :FormattedString, "#{__dir__}/data_types/formatted_string"
      autoload :Iso15924Code, "#{__dir__}/data_types/iso15924_code"
      autoload :Iso3166Code, "#{__dir__}/data_types/iso3166_code"
      autoload :Iso639Code, "#{__dir__}/data_types/iso639_code"
      autoload :Iso8601DateTime, "#{__dir__}/data_types/iso8601_date_time"
      autoload :LocalizedString, "#{__dir__}/data_types/localized_string"
      autoload :StringFormat, "#{__dir__}/data_types/string_format"
      autoload :Uri, "#{__dir__}/data_types/uri"
    end
  end
end
