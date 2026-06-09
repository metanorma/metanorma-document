# frozen_string_literal: true

module Metanorma
  module Html
    class Theme < Lutaml::Model::Serializable
      THEMES_DIR = File.join(File.dirname(__FILE__), "..", "..", "..", "data",
                             "themes")
      TEMPLATES_ROOT = File.join(File.dirname(__FILE__), "templates")

      # --- Primary palette ---
      attribute :primary, :string, default: -> { "#28388A" }
      attribute :accent, :string, default: -> { "#9C60C1" }
      attribute :gradient, :string, default: -> {
        "linear-gradient(135deg, #28388A 0%, #3a4ba0 50%, #9C60C1 100%)"
      }
      attribute :primary_light, :string, default: -> { "#eef0f8" }
      attribute :accent_light, :string, default: -> { "#f5eef9" }
      attribute :primary_dark, :string, default: -> { "#1c2660" }
      attribute :accent_deep, :string
      attribute :warm, :string
      attribute :warm_light, :string

      # --- Text & backgrounds ---
      attribute :text_color, :string, default: -> { "#1a1a2e" }
      attribute :text_light, :string, default: -> { "#4a4a6a" }
      attribute :text_muted, :string, default: -> { "#8888a0" }
      attribute :bg, :string, default: -> { "#fff" }
      attribute :bg_light, :string, default: -> { "#fafbff" }
      attribute :border, :string, default: -> { "#e0e2ee" }
      attribute :sidebar_bg, :string, default: -> { "#f7f7fc" }

      # --- Typography ---
      attribute :font_body, :string, default: -> {
        '"Source Serif 4", "Noto Serif", Georgia, "Times New Roman", serif'
      }
      attribute :font_sans, :string, default: -> {
        '"DM Sans", "Helvetica Neue", Arial, sans-serif'
      }
      attribute :font_mono, :string, default: -> {
        '"JetBrains Mono", "Fira Code", "Courier New", monospace'
      }
      attribute :font_url, :string, default: -> { "https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300..700;1,9..40,300..700&family=Source+Serif+4:ital,opsz,wght@0,8..60,300..700;1,8..60,300..700&family=JetBrains+Mono:wght@400;500&display=swap" }

      # --- Layout constants ---
      attribute :content_max_width, :string, default: -> { "50em" }
      attribute :sidebar_width, :string, default: -> { "260px" }
      attribute :header_height, :string, default: -> { "52px" }
      attribute :radius_sm, :string, default: -> { "4px" }
      attribute :radius_md, :string, default: -> { "8px" }
      attribute :shadow_sm, :string, default: -> {
        "0 1px 3px rgba(40,56,138,0.08)"
      }
      attribute :shadow_md, :string, default: -> {
        "0 4px 12px rgba(40,56,138,0.12)"
      }

      # --- Block element colors ---
      attribute :note_color, :string, default: -> { "var(--mn-accent)" }
      attribute :note_bg, :string, default: -> { "var(--mn-accent-light)" }
      attribute :note_border, :string, default: -> { "var(--mn-accent)" }
      attribute :example_color, :string, default: -> { "#0d9488" }
      attribute :example_bg, :string, default: -> { "rgba(232, 248, 245, 0.6)" }
      attribute :example_border, :string, default: -> { "#0d9488" }
      attribute :admonition_color, :string, default: -> { "#b8860b" }
      attribute :admonition_bg, :string, default: -> {
        "rgba(255, 252, 245, 0.8)"
      }
      attribute :admonition_border, :string, default: -> { "#e8a820" }

      # --- Footer & cover ---
      attribute :footer_border_color, :string
      attribute :cover_separator_color, :string

      # --- Computed CSS (gradients) ---
      attribute :header_background, :string
      attribute :cover_background, :string
      attribute :cover_after_bg, :string
      attribute :cover_before_bg, :string
      attribute :progress_bar_color, :string

      # --- Dark mode overrides ---
      attribute :dark_bg, :string, default: -> { "#0f1118" }
      attribute :dark_bg_light, :string, default: -> { "#1a1d2a" }
      attribute :dark_border, :string, default: -> { "#2e3248" }
      attribute :dark_sidebar, :string, default: -> { "#141620" }
      attribute :dark_text, :string, default: -> { "#e2e6f0" }
      attribute :dark_text_light, :string, default: -> { "#c0c8dc" }
      attribute :dark_text_muted, :string, default: -> { "#96a0b8" }
      attribute :dark_primary_light, :string, default: -> { "#1e2140" }
      attribute :dark_accent_light, :string, default: -> { "#2a2040" }
      attribute :dark_note_bg, :string
      attribute :dark_example_bg, :string
      attribute :dark_admonition_bg, :string
      attribute :dark_code_bg, :string
      attribute :dark_code_border, :string

      # --- Arbitrary per-element CSS overrides ---
      attribute :extra_css, :string

      # --- Publisher metadata ---
      attribute :publishers, :string, collection: true, default: -> { [] }
      attribute :publisher_name, :string
      attribute :logos_light, :hash, default: -> { {} }
      attribute :logos_dark, :hash, default: -> { {} }
      attribute :doctype_labels, :hash, default: -> { {} }

      # --- Document identifier formatting ---
      attribute :doc_id_strip_prefix, :string

      # --- Section ordering ---
      attribute :preface_order, :string, collection: true, default: -> {
        %w[foreword introduction abstract clause acknowledgements executivesummary]
      }
      attribute :clause_order, :string, collection: true, default: -> {
        %w[sections annex bibliography indexsect]
      }
      attribute :preface_wrap, :boolean, default: -> { false }
      attribute :toc_filter_types, :string, collection: true, default: -> { [] }

      # --- Non-YAML state (set programmatically) ---
      attr_accessor :theme_dir

      def self.load(flavor)
        dir_theme = File.join(THEMES_DIR, flavor.to_s, "theme.yaml")
        flat_theme = File.join(THEMES_DIR, "#{flavor}.yaml")

        if File.exist?(dir_theme)
          from_directory(dir_theme, flavor)
        elsif File.exist?(flat_theme)
          from_file(flat_theme)
        else
          new
        end
      end

      def self.from_file(path)
        from_yaml(File.read(path))
      end

      def self.from_directory(path, flavor)
        theme = from_yaml(File.read(path))
        theme.theme_dir = File.join(THEMES_DIR, flavor.to_s)
        theme
      end

      def logos
        logos_light
      end

      def theme_templates_dir
        return nil unless theme_dir

        dir = File.join(theme_dir, "templates")
        File.directory?(dir) ? dir : nil
      end

      def theme_assets_dir
        return nil unless theme_dir

        dir = File.join(theme_dir, "assets")
        File.directory?(dir) ? dir : nil
      end

      def theme_css_path
        return nil unless theme_dir

        path = File.join(theme_dir, "custom.css")
        File.exist?(path) ? path : nil
      end

      def resolve_template(template_name)
        if theme_templates_dir
          flavor_path = File.join(theme_templates_dir, template_name)
          return flavor_path if File.exist?(flavor_path)
        end
        File.join(TEMPLATES_ROOT, template_name)
      end

      def resolve_asset(filename)
        if theme_assets_dir
          flavor_path = File.join(theme_assets_dir, filename)
          return flavor_path if File.exist?(flavor_path)
        end
        nil
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
