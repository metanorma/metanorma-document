# frozen_string_literal: true

require "fileutils"
require "nokogiri"

module Metanorma
  module Mirror
    module Output
      module Formats
        class InlineFormat < BaseFormat
          # Classic content styles inlined for the no-JS SSR body: reset +
          # typography + block/inline component styles from the classic
          # asset pipeline. Page chrome (layout, print, transitions, dark,
          # cover, header, footer, toc, search, progress, shortcuts,
          # glossary panel, flavor modules) is owned by the SPA and
          # excluded.
          CONTENT_CSS_MODULES = %w[
            base/_reset
            base/_typography
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
            components/index
          ].freeze

          class << self
            attr_accessor :missing_bundle_warned
          end

          def write(output_path, guide, title: "Metanorma")
            FileUtils.mkdir_p(File.dirname(output_path))

            warn_missing_bundle unless iife_bundle_exists?

            data_script = "window.METANORMA_DATA = #{safe_json(guide.to_h)};"
            ssr_body = render_ssr_body(guide)
            head_parts = [build_style(classic_content_css)]
            css_inline = read_css_inline
            if css_inline && !css_inline.empty?
              head_parts << build_style(css_inline)
            end
            head_parts << build_script_src("app.iife.js") if iife_bundle_exists?
            head_extra = head_parts.join("\n")

            html = html_boilerplate(
              title: title,
              body_content: ssr_body,
              head_extra: head_extra,
              script_data: data_script,
              app_mount_id: iife_bundle_exists? ? "metanorma-app" : nil,
            )

            File.write(output_path, html)

            if iife_bundle_exists?
              copy_if_exists(iife_bundle_path,
                             File.join(File.dirname(output_path),
                                       "app.iife.js"))
            end

            output_path
          end

          private

          # SSR body is the classic renderer's document body: identical to
          # the static HTML output, embedded as the no-JS / first-paint
          # placeholder the SPA replaces on mount.
          def render_ssr_body(guide)
            document = guide.document
            unless document
              raise ArgumentError,
                    "InlineFormat requires a Guide carrying its source document"
            end

            renderer = Metanorma::Html::Generator.renderer_for(document).new
            renderer.generate_body(document)
          end

          def classic_content_css
            css_dir = Metanorma::Html::AssetPipeline::CSS_DIR
            CONTENT_CSS_MODULES.filter_map do |mod|
              path = File.join(css_dir, "#{mod}.css")
              File.read(path) if File.exist?(path)
            end.join("\n")
          end

          def warn_missing_bundle
            return if self.class.missing_bundle_warned

            warn "metanorma-document: #{iife_bundle_path} not found — " \
                 "writing static HTML without the interactive SPA. " \
                 "Run `rake build_frontend` to build it."
            self.class.missing_bundle_warned = true
          end

          def build_style(css)
            Nokogiri::HTML5::Builder.new do |doc|
              doc.style { doc.text css }
            end.doc.root.to_html
          end

          def build_script_src(src)
            Nokogiri::HTML5::Builder.new do |doc|
              doc.script(src: src)
            end.doc.root.to_html
          end

          def read_css_inline
            path = iife_css_path
            File.exist?(path) ? File.read(path) : ""
          end

          def copy_if_exists(src, dst)
            return unless File.exist?(src)

            unless File.exist?(dst) && FileUtils.identical?(
              src, dst
            )
              FileUtils.cp(src,
                           dst)
            end
          end
        end
      end
    end
  end
end

Metanorma::Mirror::Output::Formats.register(
  :inline,
  Metanorma::Mirror::Output::Formats::InlineFormat,
)
