# frozen_string_literal: true

require "fileutils"
require "json"

module Metanorma
  module Mirror
    module Output
      module Formats
        class InlineFormat < BaseFormat
          def write(output_path, guide, title: "Metanorma")
            FileUtils.mkdir_p(File.dirname(output_path))

            data_script = "window.METANORMA_DATA = #{safe_json(guide)};"
            ssr_body = HtmlRenderer.new(guide).render
            css_inline = read_css_inline
            head_parts = []

            head_parts << "<style>\n#{css_inline}\n</style>" unless css_inline.empty?
            head_parts << %(<script src="app.iife.js"></script>) if iife_bundle_exists?

            html = html_boilerplate(
              title: title,
              body_content: ssr_body,
              head_extra: head_parts.join("\n"),
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

Metanorma::Mirror::Output::Formats::FORMAT_MAP[:inline] =
  Metanorma::Mirror::Output::Formats::InlineFormat
