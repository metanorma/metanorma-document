# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module BibData
        # The extension point of the bibliographic description of a BasicDocument.
        class BibDataExtensionType < Lutaml::Model::Serializable
          attribute :doctype, Metanorma::Document::Components::BibData::DocumentType

          xml do
            element "ext"
            map_element "doctype", to: :doctype
          end
        end
      end
    end
  end
end
