# frozen_string_literal: true

module Metanorma
  module CcDocument
    module Metadata
      autoload :CcBibDataExtensionType,
               "#{__dir__}/metadata/cc_bib_data_extension_type"
      autoload :CcBibliographicItem, "#{__dir__}/metadata/cc_bibliographic_item"
    end
  end
end
