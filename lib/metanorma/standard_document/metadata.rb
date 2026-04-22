# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Metadata
      autoload :EditorialGroupType, "#{__dir__}/metadata/editorial_group_type"
      autoload :IcsType, "#{__dir__}/metadata/ics_type"
      autoload :StandardBibData, "#{__dir__}/metadata/standard_bib_data"
      autoload :StandardBibDataExtensionType,
               "#{__dir__}/metadata/standard_bib_data_extension_type"
      autoload :StructuredIdentifierType,
               "#{__dir__}/metadata/structured_identifier_type"
      autoload :TechnicalCommitteeType,
               "#{__dir__}/metadata/technical_committee_type"
    end
  end
end
