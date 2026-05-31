# frozen_string_literal: true

module Metanorma
  module BipmDocument
    module Metadata
      class BipmBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, BipmBibDataExtensionType
        attribute :depiction, DepictionElement

        xml do
          element "bibdata"
          map_element "depiction", to: :depiction
        end
      end
    end
  end
end
