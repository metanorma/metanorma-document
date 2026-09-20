# frozen_string_literal: true

module Metanorma
  module BsiDocument
    module Metadata
      autoload :BsiBibDataExtensionType,
               "#{__dir__}/metadata/bsi_bib_data_extension_type"
      autoload :BsiBibliographicItem,
               "#{__dir__}/metadata/bsi_bibliographic_item"
    end
  end
end
