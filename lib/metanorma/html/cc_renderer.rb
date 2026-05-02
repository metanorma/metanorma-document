# frozen_string_literal: true

module Metanorma
  module Html
    # Renders CcDocument (CalConnect) components to HTML.
    # Extends IsoRenderer with CalConnect branding.
    class CcRenderer < IsoRenderer
      registers_doc_type Metanorma::CcDocument::Root

      def flavor_publishers(_doc_id)
        ["CalConnect"]
      end

      def flavor_publisher_name
        "CalConnect"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.font_body      = '"Lora", "Georgia", serif'
          t.font_sans      = '"Karla", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"JetBrains Mono", "Fira Code", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,500;0,600;0,700;1,400&family=Karla:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap"
          t.primary        = "#003d7c"
          t.accent         = "#0078d4"
          t.accent_deep    = "#005fa3"
          t.gradient       = "linear-gradient(135deg, #002244 0%, #003d7c 50%, #0078d4 100%)"
          t.primary_light  = "#edf3fa"
          t.accent_light   = "#e0effc"
          t.warm           = "#c9982e"
          t.warm_light     = "#fdf8ec"
          t.header_background = "linear-gradient(135deg, #002244 0%, #003d7c 50%, #0078d4 100%)"
          t.cover_background  = "linear-gradient(175deg, #001a33 0%, #003d7c 40%, #0078d4 80%, #0092d6 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 25% 15%, rgba(0,120,212,0.2) 0%, transparent 50%), radial-gradient(ellipse at 75% 85%, rgba(201,152,46,0.15) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #c9982e, transparent)"
          t.progress_bar_color = "#0078d4"
          t.note_border     = "#0078d4"
          t.note_bg         = "#e0effc"
          t.note_color      = "#0078d4"
          t.example_border  = "#003d7c"
          t.example_bg      = "#edf3fa"
          t.example_color   = "#003d7c"
          t.admonition_border = "#c9982e"
          t.admonition_color  = "#c9982e"
          t.footer_border_color = "#0078d4"
          t.cover_separator_color = "rgba(0,120,212,0.25)"
        end
      end
    end
  end
end
