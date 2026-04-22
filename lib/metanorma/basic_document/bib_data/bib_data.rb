# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module BibData
      # The bibliographic description of a BasicDocument.
      # BibData differs from BibliographicItem by making `title` and `copyright` mandatory.
      class BibData < Lutaml::Model::Serializable
        attribute :ext, Metanorma::BasicDocument::BibData::BibDataExtensionType

        xml do
          element "ext"
          map_element "ext", to: :ext
        end
      end
    end
  end
end
