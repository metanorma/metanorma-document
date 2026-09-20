# frozen_string_literal: true

module Metanorma
  module IeeeDocument
    module Metadata
      # The bibliographical description of an IEEE document.
      # IEEE adds keyword in bibdata and IEEE-specific structured identifier.
      class IeeeBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, IeeeBibDataExtensionType
        attribute :keyword, :string, collection: true

        xml do
          element "bibdata"
          map_element "ext", to: :ext
          map_element "keyword", to: :keyword
        end
      end
    end
  end
end
