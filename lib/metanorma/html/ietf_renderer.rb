# frozen_string_literal: true

module Metanorma
  module Html
    # Renders IetfDocument components to HTML.
    # Extends IsoRenderer with IETF/RFC branding.
    class IetfRenderer < IsoRenderer
      registers_doc_type Metanorma::IetfDocument::Root

      def flavor_publishers(_doc_id)
        ["IETF"]
      end

      def flavor_publisher_name
        "IETF"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.primary        = "#333"
          t.accent         = "#c44536"
          t.accent_deep    = "#a3362b"
          t.gradient       = "linear-gradient(135deg, #1a1a1a 0%, #333 50%, #4d4d4d 100%)"
          t.primary_light  = "#f5f5f5"
          t.accent_light   = "#fdf0ee"
          t.warm           = "#c9982e"
          t.warm_light     = "#fdf8ec"
          t.font_body      = '"Roboto Slab", "Georgia", serif'
          t.font_sans      = '"Inter", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"JetBrains Mono", "Fira Code", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Roboto+Slab:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap"
          t.header_background = "linear-gradient(135deg, #1a1a1a 0%, #333 50%, #4d4d4d 100%)"
          t.cover_background  = "linear-gradient(175deg, #0d0d0d 0%, #1a1a1a 30%, #333 65%, #4d4d4d 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 30% 20%, rgba(196,69,54,0.15) 0%, transparent 50%), radial-gradient(ellipse at 70% 80%, rgba(77,77,77,0.2) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 2px; background: linear-gradient(90deg, transparent, #c44536, transparent)"
          t.progress_bar_color = "#c44536"
          t.note_border     = "#c44536"
          t.note_bg         = "#fdf0ee"
          t.note_color      = "#c44536"
          t.example_border  = "#333"
          t.example_bg      = "#f5f5f5"
          t.example_color   = "#333"
          t.admonition_border = "#c9982e"
          t.admonition_color  = "#c9982e"
          t.footer_border_color = "#c44536"
          t.cover_separator_color = "rgba(196,69,54,0.25)"
          t.extra_css = <<~CSS
            .sourcecode pre { background: #1a1a1a; border-color: #333; color: #e0e0e0; }
          CSS
        end
      end
    end
  end
end
