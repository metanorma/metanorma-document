# frozen_string_literal: true

module Metanorma
  module NistDocument
    class Root < Lutaml::Model::Serializable
      include Metanorma::StandardDocument::RootAttributes

      def self.lutaml_default_register
        :nist_document
      end

      attribute :bibdata, Metadata::NistBibliographicItem
      attribute :preface,
                NistDocument::Sections::NistPreface
      attribute :sections,
                Metanorma::StandardDocument::Sections::Sections
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
