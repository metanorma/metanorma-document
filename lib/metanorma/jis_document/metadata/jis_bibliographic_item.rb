# frozen_string_literal: true

module Metanorma
  module JisDocument
    module Metadata
      class JisBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, JisBibDataExtensionType

        xml do
          element "bibdata"
        end
      end
    end
  end
end
