# frozen_string_literal: true

module Metanorma
  module BipmDocument
    module Metadata
      # Depiction element containing image/SVG content.
      class DepictionElement < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          element "depiction"
          map_attribute "type", to: :type
          map_all_content to: :content
        end
      end

      # The bibliographical description of a BIPM document.
      # Inherits all ISO bibdata fields; BIPM adds depiction.
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
