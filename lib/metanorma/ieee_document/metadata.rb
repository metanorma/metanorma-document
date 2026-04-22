# frozen_string_literal: true

module Metanorma
  module IeeeDocument
    module Metadata
      autoload :IeeeBibDataExtensionType,
               "#{__dir__}/metadata/ieee_bib_data_extension_type"
      autoload :IeeeBibliographicItem,
               "#{__dir__}/metadata/ieee_bibliographic_item"
      autoload :IeeeStructuredIdentifier,
               "#{__dir__}/metadata/ieee_structured_identifier"
    end
  end
end
