# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module BibData
      # The extension point of the bibliographic description of a BasicDocument.
      class BibDataExtensionType < Lutaml::Model::Serializable
        attribute :doctype, Metanorma::BasicDocument::BibData::DocumentType

        xml do
          element "doctype"
          map_element "doctype", to: :doctype
        end
      end
    end
  end
end
