# frozen_string_literal: true

module Metanorma
  module RiboseDocument
    module Metadata
      # Bibliographical description of a Ribose document.
      # Inherits all ISO bibliographic fields; overrides ext for Ribose format.
      class RiboseBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, RiboseBibDataExtensionType

        xml do
          element "bibdata"
          map_element "ext", to: :ext
        end
      end
    end
  end
end
