# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module IdElements
      # Container for image content.
      class Image < Metanorma::BasicDocument::IdElements::Media
        attribute :height, :string
        attribute :width, :string

        xml do
          element "image"
          map_attribute "height", to: :height
          map_attribute "width", to: :width
        end
      end
    end
  end
end
