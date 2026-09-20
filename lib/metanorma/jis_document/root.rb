# frozen_string_literal: true

module Metanorma
  module JisDocument
    class Root < Lutaml::Model::Serializable
      include Metanorma::StandardDocument::RootAttributes

      def self.lutaml_default_register
        :jis_document
      end

      attribute :bibdata, Metadata::JisBibliographicItem
      attribute :preface,
                Metanorma::IsoDocument::Sections::IsoPreface
      attribute :sections,
                Metanorma::IsoDocument::Sections::IsoSections
      attribute :annex,
                JisDocument::Sections::JisAnnexSection,
                collection: true

      xml do
        element "metanorma"
        namespace Metanorma::StandardDocument::Namespace

        Metanorma::StandardDocument::RootXmlMapping.apply(self)
      end
    end
  end
end
