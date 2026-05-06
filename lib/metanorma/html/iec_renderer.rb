# frozen_string_literal: true

module Metanorma
  module Html
    # IEC brand: #0061a9 blue from logo
    class IecRenderer < IsoRenderer

      def flavor_publishers(_doc_id)
        ["IEC"]
      end

      def flavor_publisher_name
        "IEC"
      end

      def publisher_logo_map
        { "IEC" => "iec-logo.svg" }
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.font_body      = '"Crimson Pro", "Georgia", "Times New Roman", serif'
          t.font_sans      = '"IBM Plex Sans", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"IBM Plex Mono", "Fira Code", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400&family=IBM+Plex+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap"
          t.primary        = "#004a83"
          t.accent         = "#0061a9"
          t.accent_deep    = "#004a83"
          t.gradient       = "linear-gradient(135deg, #00305a 0%, #004a83 50%, #0061a9 100%)"
          t.primary_light  = "#ebf3f9"
          t.accent_light   = "#d9ecf7"
          t.warm           = "#d4a017"
          t.warm_light     = "#fdf6e8"
          t.header_background = "linear-gradient(135deg, #00305a 0%, #004a83 40%, #0061a9 100%)"
          t.cover_background  = "linear-gradient(175deg, #001f3d 0%, #00305a 25%, #004a83 55%, #0061a9 85%, #3391c4 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 20% 10%, rgba(0,97,169,0.2) 0%, transparent 50%), radial-gradient(ellipse at 80% 90%, rgba(212,160,23,0.1) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #0061a9, #d4a017, transparent)"
          t.progress_bar_color = "#0061a9"
          t.note_border     = "#0061a9"
          t.note_bg         = "#d9ecf7"
          t.note_color      = "#0061a9"
          t.example_border  = "#004a83"
          t.example_bg      = "#ebf3f9"
          t.example_color   = "#004a83"
          t.admonition_border = "#d4a017"
          t.admonition_color  = "#b8860b"
          t.footer_border_color = "#0061a9"
          t.cover_separator_color = "rgba(0,97,169,0.25)"
        end
      end
    end
  end
end
