# frozen_string_literal: true

module Metanorma
  module CcDocument
    module Metadata
      # The bibliographical description of a CC document.
      # Inherits all ISO bibdata fields; CC adds nothing extra.
      class CcBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, CcBibDataExtensionType

        xml do
          element "bibdata"
        end
      end
    end
  end
end
