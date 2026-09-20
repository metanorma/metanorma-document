# frozen_string_literal: true

module Metanorma
  module IeeeDocument
    class Root < Lutaml::Model::Serializable
      include Metanorma::StandardDocument::RootAttributes

      def self.lutaml_default_register
        :ieee_document
      end

      attribute :bibdata, Metadata::IeeeBibliographicItem
      attribute :preface,
                Metanorma::StandardDocument::Sections::Preface
      attribute :sections,
                IeeeDocument::Sections::IeeeSections
      attribute :annex,
                Metanorma::StandardDocument::Sections::AnnexSection,
                collection: true

      xml do
        element "metanorma"
        namespace Metanorma::StandardDocument::Namespace

        Metanorma::StandardDocument::RootXmlMapping.apply(self)
      end
    end
  end
end
