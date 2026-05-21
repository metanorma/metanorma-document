# frozen_string_literal: true

module Metanorma
  module PlateauDocument
    module Metadata
      class PlateauBibliographicItem < Metanorma::JisDocument::Metadata::JisBibliographicItem
        xml do
          element "bibdata"
        end
      end
    end
  end
end
