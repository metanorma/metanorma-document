# frozen_string_literal: true

module Metanorma
  module Html
    # ITU brand: #0e99d5 blue from logo
    class ItuRenderer < IsoRenderer

      def flavor_publishers(_doc_id)
        ["ITU"]
      end

      def flavor_publisher_name
        "ITU"
      end

      def publisher_logo_map
        { "ITU" => "itu-logo.svg" }
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.primary        = "#0a7bac"
          t.accent         = "#0e99d5"
          t.accent_deep    = "#0a7bac"
          t.gradient       = "linear-gradient(135deg, #065a83 0%, #0a7bac 50%, #0e99d5 100%)"
          t.primary_light  = "#e8f4fa"
          t.accent_light   = "#daedf8"
          t.warm           = "#b8860b"
          t.warm_light     = "#fdf5e6"
          t.sidebar_bg     = "#f2f6fa"
          t.font_body      = '"Noto Serif", "Georgia", serif'
          t.font_sans      = '"Noto Sans", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"Noto Sans Mono", "Menlo", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Noto+Sans:wght@400;500;600;700&family=Noto+Serif:ital,wght@0,400;0,500;0,600;1,400&family=Noto+Sans+Mono:wght@400;500&display=swap"
          t.header_background = "linear-gradient(135deg, #065a83 0%, #0a7bac 40%, #0e99d5 100%)"
          t.cover_background  = "linear-gradient(175deg, #043d5c 0%, #065a83 25%, #0a7bac 55%, #0e99d5 85%, #47b5e3 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 30% 15%, rgba(14,153,213,0.2) 0%, transparent 50%), radial-gradient(ellipse at 70% 80%, rgba(184,134,11,0.1) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #0e99d5, #b8860b, transparent)"
          t.progress_bar_color = "#0e99d5"
          t.note_border     = "#0e99d5"
          t.note_bg         = "#daedf8"
          t.note_color      = "#0e99d5"
          t.example_border  = "#0a7bac"
          t.example_bg      = "#e8f4fa"
          t.example_color   = "#0a7bac"
          t.admonition_border = "#b8860b"
          t.admonition_color  = "#b8860b"
          t.footer_border_color = "#0e99d5"
          t.cover_separator_color = "rgba(14,153,213,0.25)"
        end
      end
    end
  end
end
