# frozen_string_literal: true

module Metanorma
  module UnDocument
    class Root < Lutaml::Model::Serializable
      include Metanorma::StandardDocument::RootAttributes

      def self.lutaml_default_register
        :un_document
      end

      attribute :bibdata, Metadata::UnBibliographicItem
      attribute :preface,
                UnDocument::Sections::UnPreface
      attribute :sections,
                UnDocument::Sections::UnSections
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
