# frozen_string_literal: true

module Metanorma
  module IetfDocument
    class Root < Lutaml::Model::Serializable
      include Metanorma::StandardDocument::RootAttributes

      def self.lutaml_default_register
        :ietf_document
      end

      attribute :bibdata,
                Metanorma::IetfDocument::Metadata::IetfBibliographicItem
      attribute :preface,
                Metanorma::StandardDocument::Sections::Preface
      attribute :sections,
                Metanorma::IetfDocument::Sections::IetfSections
      attribute :annex,
                Metanorma::IetfDocument::Sections::IetfAnnexSection,
                collection: true

      xml do
        element "metanorma"
        namespace Metanorma::StandardDocument::Namespace

        Metanorma::StandardDocument::RootXmlMapping.apply(self)
      end
    end
  end
end
