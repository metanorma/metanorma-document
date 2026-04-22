# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module BibData
        autoload :BibData, "#{__dir__}/bib_data/bib_data"
        autoload :BibDataExtensionType,
                 "#{__dir__}/bib_data/bib_data_extension_type"
        autoload :BibliographicItem, "#{__dir__}/bib_data/bibliographic_item"
        autoload :DocumentType, "#{__dir__}/bib_data/document_type"
      end
    end
  end
end
