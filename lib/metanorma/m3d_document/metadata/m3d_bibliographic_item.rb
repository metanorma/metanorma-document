# frozen_string_literal: true

module Metanorma
  module M3dDocument
    module Metadata
      class M3dBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, M3dBibDataExtensionType

        xml do
          element "bibdata"
        end
      end
    end
  end
end
