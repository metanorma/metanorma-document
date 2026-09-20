# frozen_string_literal: true

module Metanorma
  module BsiDocument
    module Metadata
      class BsiBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, BsiBibDataExtensionType

        xml do
          element "bibdata"
        end
      end
    end
  end
end
