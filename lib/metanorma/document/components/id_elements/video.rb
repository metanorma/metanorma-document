# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module IdElements
        # Container for video content.
        class Video < Media
          attribute :altsource, AltSource, collection: true
          attribute :height, :string
          attribute :width, :string

          xml do
            element "video"
            map_element "alt-source", to: :altsource
            map_attribute "height", to: :height
            map_attribute "width", to: :width
          end
        end
      end
    end
  end
end
