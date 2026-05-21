# frozen_string_literal: true

module Metanorma
  module NistDocument
    module Metadata
      autoload :NistBibDataExtensionType,
               "#{__dir__}/metadata/nist_bib_data_extension_type"
      autoload :NistBibliographicItem,
               "#{__dir__}/metadata/nist_bibliographic_item"
    end
  end
end
