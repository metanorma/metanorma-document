# frozen_string_literal: true

module Metanorma
  module RiboseDocument
    module Metadata
      autoload :RiboseBibDataExtensionType,
               "#{__dir__}/metadata/ribose_bib_data_extension_type"
      autoload :RiboseBibliographicItem,
               "#{__dir__}/metadata/ribose_bibliographic_item"
    end
  end
end
