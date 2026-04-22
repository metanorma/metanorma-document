# frozen_string_literal: true

module Metanorma
  module BipmDocument
    module Metadata
      autoload :BipmBibDataExtensionType,
               "#{__dir__}/metadata/bipm_bib_data_extension_type"
      autoload :BipmBibliographicItem,
               "#{__dir__}/metadata/bipm_bibliographic_item"
      autoload :BipmStructuredIdentifier,
               "#{__dir__}/metadata/bipm_structured_identifier"
      autoload :DepictionElement, "#{__dir__}/metadata/bipm_bibliographic_item"
    end
  end
end
