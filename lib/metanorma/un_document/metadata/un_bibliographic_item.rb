# frozen_string_literal: true

module Metanorma
  module UnDocument
    module Metadata
      class UnBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :ext, UnBibDataExtensionType

        xml do
          element "bibdata"
        end
      end
    end
  end
end
