# frozen_string_literal: true

module Metanorma
  module NistDocument
    module Metadata
      class NistBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, NistBibDataExtensionType

        xml do
          element "bibdata"
        end
      end
    end
  end
end
