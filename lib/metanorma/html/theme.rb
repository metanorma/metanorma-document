# frozen_string_literal: true

require "yaml"

module Metanorma
  module Html
    class Theme < Lutaml::Model::Serializable
      THEMES_DIR = File.join(File.dirname(__FILE__), "..", "..", "..", "data",
                             "themes")
      TEMPLATES_ROOT = File.join(File.dirname(__FILE__), "templates")
      BOOLEAN_VALUES = [true, false].freeze

      # Explicit composition: defaults belong to the selected parent, never to
      # an unregistered flavor fallback. Child logo maps replace parent maps.
      attribute :extends, :string

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
      # Template paths resolve through the flavor theme directory first.
      attribute :cover_template, :string
      attribute :titlepage_template, :string
      attribute :intro_template, :string
      attribute :boilerplate_placement, :string, default: -> { "after_cover" }
      attribute :cover_notes_slot, :string, default: -> { "cover" }

      attribute :preface_order, :string, collection: true, default: -> {
        %w[foreword introduction abstract clause acknowledgements executivesummary]
      }
      attribute :clause_order, :string, collection: true, default: -> {
        %w[sections annex bibliography indexsect]
      }
      attribute :preface_wrap, :boolean, default: -> { false }
      attribute :toc_filter_types, :string, collection: true, default: -> { [] }

      # --- Non-YAML state (set programmatically) ---
      attr_accessor :theme_dir, :inherited_theme_dirs

      # Additional theme directories registered by flavor gems (e.g.
      # metanorma-oiml). Searched before the built-in THEMES_DIR so a
      # flavor can ship its own `themes/<flavor>/theme.yaml` (directory
      # form, with assets/templates/custom.css alongside) outside this gem.
      @extra_themes_dirs = []

      class << self
        attr_reader :extra_themes_dirs

        def register_themes_dir(dir)
          @extra_themes_dirs.unshift(File.expand_path(dir))
        end

        def themes_dirs
          @extra_themes_dirs + [THEMES_DIR]
        end
      end

      def self.load(flavor, chain: [])
        name = flavor.to_s
        unless /\A[a-z0-9][a-z0-9_-]*\z/.match?(name)
          raise ArgumentError, "Invalid theme name: #{name.inspect}"
        end
        if chain.include?(name)
          raise ArgumentError, "Theme inheritance cycle: #{(chain + [name]).join(' -> ')}"
        end

        themes_dirs.each do |root|
          directory = File.join(root, name, "theme.yaml")
          flat = File.join(root, "#{name}.yaml")
          path = [directory, flat].find { |candidate| File.file?(candidate) }
          next unless path

          dir = path == directory ? File.dirname(path) : nil
          return from_config(path, dir, chain + [name])
        end
        raise ArgumentError, "Unknown HTML theme: #{name}"
      end

      def self.from_file(path)
        from_config(path, nil, [])
      end

      def self.from_directory(path, flavor, themes_dir = THEMES_DIR)
        from_config(path, File.join(themes_dir, flavor.to_s), [flavor.to_s])
      end

      def self.from_theme_dir(dir)
        from_config(File.join(dir, "theme.yaml"), dir, [])
      end

      def self.from_config(path, dir, chain)
        config = YAML.safe_load_file(path, aliases: false)
        validate_config!(config, path)
        parent = load(config["extends"], chain: chain) if config["extends"]
        # Only explicit child keys replace parent values, including empty maps
        # and arrays. Deserializing the child first would inject its defaults.
        inherited = parent ? YAML.safe_load(parent.to_yaml, aliases: false) : {}
        theme = from_yaml(inherited.merge(config).to_yaml)
        theme.theme_dir = dir
        theme.inherited_theme_dirs = parent ? parent.resource_dirs : []
        theme
      end

      def self.validate_config!(config, path)
        raise ArgumentError, "Theme must be a mapping: #{path}" unless config.is_a?(Hash)

        config.each do |key, value|
          definition = attributes[key.to_sym] if key.is_a?(String)
          raise ArgumentError, "Unknown theme key #{key.inspect}: #{path}" unless definition
          next if value.nil?

          valid = if definition.collection?
                    value.is_a?(Array) && value.all?(String)
                  elsif definition.type == Lutaml::Model::Type::Hash
                    value.is_a?(Hash) && value.all? { |k, v| k.is_a?(String) && v.is_a?(String) }
                  elsif definition.type == Lutaml::Model::Type::Boolean
                    BOOLEAN_VALUES.include?(value)
                  else
                    value.is_a?(String)
                  end
          raise ArgumentError, "Invalid theme value for #{key}: #{path}" unless valid
        end
      end

      # Theme resource APIs search the same composition chain as the data.
      def resource_dirs
        [theme_dir, *inherited_theme_dirs].compact.uniq
      end

      def logos
        logos_light
      end

      def theme_templates_dir
        theme_template_directories.first
      end

      def theme_template_directories
        resource_dirs.map { |dir| File.join(dir, "templates") }
          .select { |dir| File.directory?(dir) }
      end

      def theme_assets_dir
        resource_dirs.map { |dir| File.join(dir, "assets") }
          .find { |dir| File.directory?(dir) }
      end

      def theme_css_path
        resource_path("custom.css")
      end

      def resolve_template(template_name)
        resource_path("templates", template_name) ||
          File.join(TEMPLATES_ROOT, template_name)
      end

      def resolve_asset(filename)
        resource_path("assets", filename)
      end

      def resource_path(*parts)
        resource_dirs.each do |dir|
          root = File.expand_path(dir)
          path = File.expand_path(File.join(root, *parts))
          unless path.start_with?("#{root}/")
            raise ArgumentError, "Theme resource escapes its directory: #{parts.join('/')}"
          end
          return path if File.file?(path)
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
