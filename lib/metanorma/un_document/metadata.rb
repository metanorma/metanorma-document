# frozen_string_literal: true

module Metanorma
  module UnDocument
    module Metadata
      autoload :UnBibDataExtensionType,
               "#{__dir__}/metadata/un_bib_data_extension_type"
      autoload :UnBibliographicItem,
               "#{__dir__}/metadata/un_bibliographic_item"
    end
  end
end
