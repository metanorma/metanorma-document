# frozen_string_literal: true

module Metanorma
  module Html
    # Renders IeeeDocument components to HTML.
    # Extends IsoRenderer with IEEE branding.
    class IeeeRenderer < IsoRenderer

      def flavor_publishers(_doc_id)
        ["IEEE"]
      end

      def flavor_publisher_name
        "IEEE"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.font_body      = '"Source Serif 4", "Georgia", serif'
          t.font_sans      = '"IBM Plex Sans", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"IBM Plex Mono", "Fira Code", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Source+Serif+4:ital,opsz,wght@0,8..60,300..700;1,8..60,300..700&family=IBM+Plex+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap"
          t.primary        = "#006699"
          t.accent         = "#0099cc"
          t.accent_deep    = "#007ab3"
          t.gradient       = "linear-gradient(135deg, #003d5c 0%, #006699 50%, #0099cc 100%)"
          t.primary_light  = "#edf5fa"
          t.accent_light   = "#e0f2fc"
          t.warm           = "#c9982e"
          t.warm_light     = "#fdf8ec"
          t.header_background = "linear-gradient(135deg, #003d5c 0%, #006699 50%, #0099cc 100%)"
          t.cover_background  = "linear-gradient(175deg, #002640 0%, #003d5c 30%, #006699 65%, #0099cc 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 25% 15%, rgba(0,153,204,0.2) 0%, transparent 50%), radial-gradient(ellipse at 75% 85%, rgba(201,152,46,0.15) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #c9982e, transparent)"
          t.progress_bar_color = "#0099cc"
          t.note_border     = "#0099cc"
          t.note_bg         = "#e0f2fc"
          t.note_color      = "#0099cc"
          t.example_border  = "#006699"
          t.example_bg      = "#edf5fa"
          t.example_color   = "#006699"
          t.admonition_border = "#c9982e"
          t.admonition_color  = "#c9982e"
          t.footer_border_color = "#0099cc"
          t.cover_separator_color = "rgba(0,153,204,0.25)"
        end
      end
    end
  end
end
