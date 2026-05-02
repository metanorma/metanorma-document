# frozen_string_literal: true

module Metanorma
  module Html
    # Renders RiboseDocument components to HTML.
    # Extends IsoRenderer with Ribose branding.
    class RiboseRenderer < IsoRenderer
      registers_doc_type Metanorma::RiboseDocument::Root

      def flavor_publishers(_doc_id)
        ["Ribose"]
      end

      def flavor_publisher_name
        "Ribose"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.font_body      = '"Noto Serif", "Georgia", serif'
          t.font_sans      = '"Noto Sans", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"JetBrains Mono", "Fira Code", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Noto+Serif:ital,wght@0,400;0,500;0,600;0,700;1,400&family=Noto+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap"
          t.primary        = "#2d1b69"
          t.accent         = "#7c3aed"
          t.accent_deep    = "#5b21b6"
          t.gradient       = "linear-gradient(135deg, #1a0e3e 0%, #2d1b69 50%, #5b21b6 100%)"
          t.primary_light  = "#f3eeff"
          t.accent_light   = "#ede5ff"
          t.warm           = "#e8912e"
          t.warm_light     = "#fef4e8"
          t.header_background = "linear-gradient(135deg, #1a0e3e 0%, #2d1b69 50%, #5b21b6 100%)"
          t.cover_background  = "linear-gradient(175deg, #0f0826 0%, #1a0e3e 25%, #2d1b69 55%, #5b21b6 80%, #7c3aed 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 30% 20%, rgba(124,58,237,0.2) 0%, transparent 50%), radial-gradient(ellipse at 70% 80%, rgba(232,145,46,0.15) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #7c3aed, transparent)"
          t.progress_bar_color = "#7c3aed"
          t.note_border     = "#7c3aed"
          t.note_bg         = "#ede5ff"
          t.note_color      = "#7c3aed"
          t.example_border  = "#2d1b69"
          t.example_bg      = "#f3eeff"
          t.example_color   = "#2d1b69"
          t.admonition_border = "#e8912e"
          t.admonition_color  = "#e8912e"
          t.footer_border_color = "#7c3aed"
          t.cover_separator_color = "rgba(124,58,237,0.25)"
        end
      end
    end
  end
end
