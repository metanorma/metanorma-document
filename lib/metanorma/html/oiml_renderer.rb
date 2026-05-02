# frozen_string_literal: true

module Metanorma
  module Html
    # Renders OimlDocument (OIML) components to HTML.
    # Extends IsoRenderer with OIML branding.
    class OimlRenderer < IsoRenderer
      registers_doc_type Metanorma::OimlDocument::Root

      def flavor_publishers(_doc_id)
        ["OIML"]
      end

      def flavor_publisher_name
        "OIML"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.font_body      = '"Merriweather", "Georgia", serif'
          t.font_sans      = '"Montserrat", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"JetBrains Mono", "Fira Code", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Merriweather:ital,wght@0,300;0,400;0,700;1,400&family=Montserrat:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap"
          t.primary        = "#1a5c3a"
          t.accent         = "#2e8b57"
          t.accent_deep    = "#247049"
          t.gradient       = "linear-gradient(135deg, #0d3d22 0%, #1a5c3a 50%, #2e8b57 100%)"
          t.primary_light  = "#edf7f1"
          t.accent_light   = "#e0f5e8"
          t.warm           = "#d4a017"
          t.warm_light     = "#fdf6e8"
          t.header_background = "linear-gradient(135deg, #0d3d22 0%, #1a5c3a 50%, #2e8b57 100%)"
          t.cover_background  = "linear-gradient(175deg, #071f14 0%, #0d3d22 30%, #1a5c3a 65%, #2e8b57 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 30% 20%, rgba(46,139,87,0.2) 0%, transparent 50%), radial-gradient(ellipse at 70% 80%, rgba(212,160,23,0.15) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #d4a017, transparent)"
          t.progress_bar_color = "#2e8b57"
          t.note_border     = "#2e8b57"
          t.note_bg         = "#e0f5e8"
          t.note_color      = "#2e8b57"
          t.example_border  = "#1a5c3a"
          t.example_bg      = "#edf7f1"
          t.example_color   = "#1a5c3a"
          t.admonition_border = "#d4a017"
          t.admonition_color  = "#d4a017"
          t.footer_border_color = "#2e8b57"
          t.cover_separator_color = "rgba(46,139,87,0.25)"
        end
      end
    end
  end
end
