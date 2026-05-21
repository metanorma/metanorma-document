# frozen_string_literal: true

module Metanorma
  module GbDocument
    module Metadata
      class GbBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, GbBibDataExtensionType

        xml do
          element "bibdata"
        end
      end
    end
  end
end
