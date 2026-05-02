# frozen_string_literal: true

module Metanorma
  module Html
    class Theme
      # Primary palette
      attr_accessor :primary, :accent, :gradient,
                    :primary_light, :accent_light, :primary_dark,
                    :accent_deep, :warm, :warm_light

      # Text & backgrounds
      attr_accessor :text_color, :text_light, :text_muted,
                    :bg, :bg_light, :border, :sidebar_bg

      # Typography
      attr_accessor :font_body, :font_sans, :font_mono, :font_url

      # Layout constants
      attr_accessor :content_max_width, :sidebar_width, :header_height,
                    :radius_sm, :radius_md, :shadow_sm, :shadow_md

      # Block element colors (driven via CSS variables, eliminates extra_css)
      attr_accessor :note_color, :note_bg, :note_border,
                    :example_color, :example_bg, :example_border,
                    :admonition_color, :admonition_bg, :admonition_border

      # Footer accent
      attr_accessor :footer_border_color

      # Cover separator
      attr_accessor :cover_separator_color

      # Computed CSS (gradients — cannot use CSS variables alone)
      attr_accessor :header_background, :cover_background,
                    :cover_after_bg, :cover_before_bg,
                    :progress_bar_color

      # Dark mode overrides
      attr_accessor :dark_bg, :dark_bg_light, :dark_border, :dark_sidebar,
                    :dark_text, :dark_text_light, :dark_text_muted,
                    :dark_primary_light, :dark_accent_light,
                    :dark_note_bg, :dark_example_bg, :dark_admonition_bg,
                    :dark_code_bg, :dark_code_border

      # Arbitrary per-element CSS overrides (search, sourcecode, etc.)
      attr_accessor :extra_css

      def initialize
        @primary        = "#28388A"
        @accent         = "#9C60C1"
        @gradient       = "linear-gradient(135deg, #28388A 0%, #3a4ba0 50%, #9C60C1 100%)"
        @primary_light  = "#eef0f8"
        @accent_light   = "#f5eef9"
        @primary_dark   = "#1c2660"
        @accent_deep    = nil
        @warm           = nil
        @warm_light     = nil
        @text_color     = "#1a1a2e"
        @text_light     = "#4a4a6a"
        @text_muted     = "#8888a0"
        @bg             = "#fff"
        @bg_light       = "#fafbff"
        @border         = "#e0e2ee"
        @sidebar_bg     = "#f7f7fc"
        @font_body      = '"Source Serif 4", "Noto Serif", Georgia, "Times New Roman", serif'
        @font_sans      = '"DM Sans", "Helvetica Neue", Arial, sans-serif'
        @font_mono      = '"JetBrains Mono", "Fira Code", "Courier New", monospace'
        @font_url       = "https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300..700;1,9..40,300..700&family=Source+Serif+4:ital,opsz,wght@0,8..60,300..700;1,8..60,300..700&family=JetBrains+Mono:wght@400;500&display=swap"
        @content_max_width = "50em"
        @sidebar_width     = "260px"
        @header_height     = "52px"
        @radius_sm = "4px"
        @radius_md = "8px"
        @shadow_sm = "0 1px 3px rgba(40,56,138,0.08)"
        @shadow_md = "0 4px 12px rgba(40,56,138,0.12)"

        # Block element defaults
        @note_color      = "var(--mn-accent)"
        @note_bg         = "var(--mn-accent-light)"
        @note_border     = "var(--mn-accent)"
        @example_color   = "#0d9488"
        @example_bg      = "rgba(232, 248, 245, 0.6)"
        @example_border  = "#0d9488"
        @admonition_color = "#b8860b"
        @admonition_bg   = "rgba(255, 252, 245, 0.8)"
        @admonition_border = "#e8a820"
        @footer_border_color = nil
        @cover_separator_color = nil

        @header_background = nil
        @cover_background  = nil
        @cover_after_bg    = nil
        @cover_before_bg   = nil
        @progress_bar_color = nil
        @extra_css         = nil

        # Dark mode defaults
        @dark_bg          = "#0f1118"
        @dark_bg_light    = "#1a1d2a"
        @dark_border      = "#2e3248"
        @dark_sidebar     = "#141620"
        @dark_text        = "#e2e6f0"
        @dark_text_light  = "#c0c8dc"
        @dark_text_muted  = "#96a0b8"
        @dark_primary_light = "#1e2140"
        @dark_accent_light  = "#2a2040"
        @dark_note_bg     = nil
        @dark_example_bg  = nil
        @dark_admonition_bg = nil
        @dark_code_bg     = nil
        @dark_code_border = nil
      end

      def to_css_root
        root = <<~CSS
          :root {
            --mn-primary: #{primary};
            --mn-accent: #{accent};
            --mn-gradient: #{gradient};
            --mn-primary-light: #{primary_light};
            --mn-accent-light: #{accent_light};
            --mn-primary-dark: #{primary_dark};
            --color-text: #{text_color};
            --color-text-light: #{text_light};
            --color-text-muted: #{text_muted};
            --color-bg: #{bg};
            --color-bg-light: #{bg_light};
            --color-border: #{border};
            --color-sidebar-bg: #{sidebar_bg};
            --font-body: #{font_body};
            --font-sans: #{font_sans};
            --font-mono: #{font_mono};
            --content-max-width: #{content_max_width};
            --sidebar-width: #{sidebar_width};
            --header-height: #{header_height};
            --radius-sm: #{radius_sm};
            --radius-md: #{radius_md};
            --shadow-sm: #{shadow_sm};
            --shadow-md: #{shadow_md};
            --note-bg: #{note_bg};
            --note-border: #{note_border};
            --note-color: #{note_color};
            --example-bg: #{example_bg};
            --example-border: #{example_border};
            --example-color: #{example_color};
            --admonition-bg: #{admonition_bg};
            --admonition-border: #{admonition_border};
            --admonition-color: #{admonition_color};
        CSS
        root += "    --mn-accent-deep: #{accent_deep};\n" if accent_deep
        root += "    --mn-warm: #{warm};\n" if warm
        root += "    --mn-warm-light: #{warm_light};\n" if warm_light
        root += "    --mn-header-bg: #{header_background};\n" if header_background
        root += "    --mn-cover-bg: #{cover_background};\n" if cover_background
        root += "    --mn-progress-color: #{progress_bar_color};\n" if progress_bar_color
        root += "    --mn-footer-border: #{footer_border_color};\n" if footer_border_color
        root += "    --mn-cover-separator: #{cover_separator_color};\n" if cover_separator_color
        root += "  }\n"
        root += generate_dark_mode_block if dark_bg
        root
      end

      def to_css_extras
        css = ""
        css += ".title-section::before { content: \"\"; position: absolute; inset: 0; pointer-events: none; #{cover_before_bg} }\n" if cover_before_bg
        css += ".title-section::after { #{cover_after_bg} }\n" if cover_after_bg
        css += extra_css.to_s if extra_css
        css
      end

      def to_css
        to_css_root + to_css_extras
      end

      private

      def generate_dark_mode_block
        css = "[data-theme=\"dark\"] {\n"
        css += "  --color-text: #{dark_text};\n" if dark_text
        css += "  --color-text-light: #{dark_text_light};\n" if dark_text_light
        css += "  --color-text-muted: #{dark_text_muted};\n" if dark_text_muted
        css += "  --color-bg: #{dark_bg};\n" if dark_bg
        css += "  --color-bg-light: #{dark_bg_light};\n" if dark_bg_light
        css += "  --color-border: #{dark_border};\n" if dark_border
        css += "  --color-sidebar-bg: #{dark_sidebar};\n" if dark_sidebar
        css += "  --mn-primary-light: #{dark_primary_light};\n" if dark_primary_light
        css += "  --mn-accent-light: #{dark_accent_light};\n" if dark_accent_light
        css += "  --note-bg: #{dark_note_bg};\n" if dark_note_bg
        css += "  --example-bg: #{dark_example_bg};\n" if dark_example_bg
        css += "  --admonition-bg: #{dark_admonition_bg};\n" if dark_admonition_bg
        css += "}\n"
        css
      end
    end
  end
end
