# frozen_string_literal: true

module Metanorma
  module Html
    # Renders ICC (International Color Consortium) taste documents to HTML.
    # ICC brand: color management — dark charcoal + steel blue + warm gray
    class IccRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["ICC"]
      end

      def flavor_publisher_name
        "ICC"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.primary        = "#3a3f47"
          t.accent         = "#4a90c4"
          t.accent_deep    = "#3a78a8"
          t.gradient       = "linear-gradient(135deg, #2a2e34 0%, #3a3f47 50%, #4a5464 100%)"
          t.primary_light  = "#eef0f2"
          t.accent_light   = "#e4eef6"
          t.warm           = "#c4956a"
          t.warm_light     = "#faf3ec"
          t.header_background = "linear-gradient(135deg, #2a2e34 0%, #3a3f47 40%, #4a5464 100%)"
          t.cover_background  = "linear-gradient(175deg, #1e2126 0%, #2a2e34 25%, #3a3f47 55%, #4a5464 85%, #4a90c4 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 30% 20%, rgba(74,144,196,0.15) 0%, transparent 50%), radial-gradient(ellipse at 70% 80%, rgba(196,149,106,0.1) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #4a90c4, #c4956a, transparent)"
          t.progress_bar_color = "#4a90c4"
          t.note_border     = "#4a90c4"
          t.note_bg         = "#e4eef6"
          t.note_color      = "#4a90c4"
          t.example_border  = "#3a3f47"
          t.example_bg      = "#eef0f2"
          t.example_color   = "#3a3f47"
          t.admonition_border = "#c4956a"
          t.admonition_color  = "#c4956a"
          t.footer_border_color = "#4a90c4"
          t.cover_separator_color = "rgba(74,144,196,0.25)"
        end
      end
    end
  end
end
