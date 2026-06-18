# frozen_string_literal: true

require "fileutils"
require "nokogiri"

module Metanorma
  module Mirror
    module Output
      module Formats
        class InlineFormat < BaseFormat
          def write(output_path, guide, title: "Metanorma")
            FileUtils.mkdir_p(File.dirname(output_path))

            data_script = "window.METANORMA_DATA = #{safe_json(guide)};"
            ssr_body = HtmlRenderer.new(guide).render
            head_parts = []
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
