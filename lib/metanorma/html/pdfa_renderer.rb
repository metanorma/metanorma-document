# frozen_string_literal: true

module Metanorma
  module Html
    # Renders PDF Association (PDFA) taste documents to HTML.
    # PDFA brand: #cf9c1d gold + #d03544 red + #4992b2 steel blue from logo
    class PdfaRenderer < IsoRenderer

      def flavor_publishers(_doc_id)
        ["PDF Association"]
      end

      def flavor_publisher_name
        "PDF Association"
      end

      def publisher_logo_map
        { "PDF Association" => "pdfa-logo.svg" }
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.primary        = "#3a6e85"
          t.accent         = "#cf9c1d"
          t.accent_deep    = "#b08518"
          t.gradient       = "linear-gradient(135deg, #2a5268 0%, #3a6e85 50%, #4992b2 100%)"
          t.primary_light  = "#eef5f8"
          t.accent_light   = "#fdf6e6"
          t.warm           = "#d03544"
          t.warm_light     = "#fdeef0"
          t.header_background = "linear-gradient(135deg, #2a5268 0%, #3a6e85 40%, #4992b2 100%)"
          t.cover_background  = "linear-gradient(175deg, #1a3848 0%, #2a5268 25%, #3a6e85 55%, #4992b2 85%, #cf9c1d 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 25% 20%, rgba(207,156,29,0.15) 0%, transparent 50%), radial-gradient(ellipse at 70% 80%, rgba(73,146,178,0.2) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #cf9c1d, #d03544, transparent)"
          t.progress_bar_color = "#cf9c1d"
          t.note_border     = "#4992b2"
          t.note_bg         = "#eef5f8"
          t.note_color      = "#4992b2"
          t.example_border  = "#3a6e85"
          t.example_bg      = "#eef5f8"
          t.example_color   = "#3a6e85"
          t.admonition_border = "#d03544"
          t.admonition_color  = "#d03544"
          t.footer_border_color = "#cf9c1d"
          t.cover_separator_color = "rgba(207,156,29,0.25)"
        end
      end
    end
  end
end
