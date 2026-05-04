# frozen_string_literal: true

module Metanorma
  module Html
    class AssetPipeline
      CSS_DIR = File.expand_path("../../../data/stylesheets", __dir__)
      JS_DIR  = File.expand_path("../../../data/javascripts", __dir__)

      CORE_JS = %w[
        core/mn-reader
        core/mn-theme
        core/mn-scroll
        core/mn-navigation
        core/mn-reveal
      ].freeze

      COMPONENT_JS = %w[
        components/mn-toc
        components/mn-search
        components/mn-lightbox
        components/mn-code-copy
        components/mn-index-panel
        components/mn-stem-dropdown
        components/mn-glossary
        components/mn-shortcuts
      ].freeze

      BASE_CSS = %w[
        base/_reset
        base/_typography
        base/_layout
        base/_transitions
        base/_dark
        base/_print
      ].freeze

      COMPONENT_CSS = %w[
        components/header
        components/cover
        components/toc
        components/search
        components/section
        components/note
        components/example
        components/sourcecode
        components/formula
        components/admonition
        components/table
        components/footnote
        components/figure
        components/term
        components/bibliography
        components/inline
        components/footer
        components/progress
        components/index
        components/shortcuts
        components/glossary
      ].freeze

      def compile_js(flavor_js: nil)
        modules = CORE_JS + COMPONENT_JS
        modules << "flavors/#{flavor_js}" if flavor_js

        js_parts = modules.filter_map do |mod|
          path = File.join(JS_DIR, "#{mod}.js")
          next unless File.exist?(path)

          wrap_iife(File.read(path), mod)
        end

        js_parts.join("\n")
      end

      def compile_css(flavor_css: nil)
        modules = BASE_CSS + COMPONENT_CSS
        modules << "flavors/#{flavor_css}" if flavor_css

        css_parts = modules.filter_map do |mod|
          path = File.join(CSS_DIR, "#{mod}.css")
          File.exist?(path) ? File.read(path) : nil
        end

        css_parts.join("\n")
      end

      private

      def wrap_iife(source, module_name)
        <<~JS
          (function() {
          try {
          #{source.strip}
          } catch(e) { if (typeof console !== 'undefined') console.error('[#{module_name}]', e); }
          })();
        JS
      end
    end
  end
end
