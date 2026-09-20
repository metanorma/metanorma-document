# frozen_string_literal: true

module Metanorma
  module BsiDocument
    class Root < Lutaml::Model::Serializable
      include Metanorma::StandardDocument::RootAttributes

      def self.lutaml_default_register
        :bsi_document
      end

      attribute :bibdata, Metadata::BsiBibliographicItem
      attribute :preface,
                Metanorma::IsoDocument::Sections::IsoPreface
      attribute :sections,
                BsiDocument::Sections::BsiSections
      attribute :annex,
                BsiDocument::Sections::BsiAnnexSection,
                collection: true

      xml do
        element "metanorma"
        namespace Metanorma::StandardDocument::Namespace

        Metanorma::StandardDocument::RootXmlMapping.apply(self)
      end
    end
  end
end
