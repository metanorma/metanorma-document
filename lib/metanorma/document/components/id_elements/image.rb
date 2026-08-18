# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module IdElements
        # Container for image content.
        class Image < Media
          attribute :height, :string
          attribute :width, :string
          attribute :align, :string
          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :inline_svg, :string

          xml do
            element "image"
            map_attribute "height", to: :height, render_empty: true
            map_attribute "width", to: :width, render_empty: true
            map_attribute "align", to: :align
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_element "svg", to: :inline_svg, raw: :element
          end
        end
      end
    end
  end
end
