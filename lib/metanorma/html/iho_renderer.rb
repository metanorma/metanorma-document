# frozen_string_literal: true

module Metanorma
  module Html
    # IHO brand: #00AAA9 teal + #05164D navy + #FEDC5B gold from logo
    class IhoRenderer < IsoRenderer

      def flavor_publishers(_doc_id)
        ["IHO"]
      end

      def flavor_publisher_name
        "IHO"
      end

      def publisher_logo_map
        { "IHO" => "iho-logo.svg" }
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.primary        = "#05164D"
          t.accent         = "#00AAA9"
          t.accent_deep    = "#008887"
          t.gradient       = "linear-gradient(135deg, #03103a 0%, #05164D 50%, #00AAA9 100%)"
          t.primary_light  = "#eaf5f5"
          t.accent_light   = "#e0f7f6"
          t.warm           = "#FEDC5B"
          t.warm_light     = "#fff9e6"
          t.sidebar_bg     = "#f0f5f8"
          t.font_body      = '"Source Serif 4", "Georgia", serif'
          t.font_sans      = '"Source Sans 3", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"Source Code Pro", "Menlo", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Source+Sans+3:ital,wght@0,400;0,500;0,600;0,700;1,400&family=Source+Serif+4:ital,wght@0,400;0,500;0,600;1,400&family=Source+Code+Pro:wght@400;500&display=swap"
          t.header_background = "linear-gradient(135deg, #03103a 0%, #05164D 40%, #00AAA9 100%)"
          t.cover_background  = "linear-gradient(175deg, #020a20 0%, #03103a 25%, #05164D 55%, #008887 85%, #00AAA9 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 30% 20%, rgba(0,170,169,0.2) 0%, transparent 50%), radial-gradient(ellipse at 70% 80%, rgba(254,220,91,0.1) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 4px; background: linear-gradient(90deg, #00AAA9, #05164D, #FEDC5B, #00AAA9)"
          t.progress_bar_color = "#00AAA9"
          t.note_border     = "#00AAA9"
          t.note_bg         = "#e0f7f6"
          t.note_color      = "#00AAA9"
          t.example_border  = "#05164D"
          t.example_bg      = "#eaf5f5"
          t.example_color   = "#008887"
          t.admonition_border = "#FEDC5B"
          t.admonition_bg   = "#fff9e6"
          t.admonition_color = "#b8860b"
          t.footer_border_color = "#00AAA9"
          t.cover_separator_color = "rgba(0,170,169,0.3)"
        end
      end
    end
  end
end
