# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module IdElements
        # Container for image content.
        class Image < Media
          attribute :height, :string
          attribute :width, :string
          attribute :semx_id, :string

          xml do
            element "image"
            map_attribute "height", to: :height, render_empty: true
            map_attribute "width", to: :width, render_empty: true
            map_attribute "semx-id", to: :semx_id
          end
        end
      end
    end
  end
end
