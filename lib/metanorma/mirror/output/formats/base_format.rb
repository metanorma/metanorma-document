# frozen_string_literal: true

require "nokogiri"

module Metanorma
  module Mirror
    module Output
      module Formats
        class BaseFormat
          attr_reader :dist_dir

          def initialize(dist_dir: nil)
            @dist_dir = dist_dir || self.class.default_dist_dir
          end

          def write(output_path, guide, title: "Metanorma")
            raise NotImplementedError, "#{self.class}#write not implemented"
          end

          class << self
            attr_accessor :configured_dist_dir

            def default_dist_dir
              @configured_dist_dir || File.expand_path(
                "../../../../../frontend/dist", __dir__
              )
            end
          end

          protected

          def safe_json(data)
            JSON.generate(data).gsub("</script", '<\\/script')
          end

          def html_boilerplate(title:, body_content:, head_extra: "",
                               script_data: nil, app_mount_id: nil)
            Nokogiri::HTML5::Builder.new do |doc|
              doc.html(lang: "en") do
                build_head(doc, title:, head_extra:, script_data:)
                build_body(doc, body_content:, app_mount_id:)
              end
            end.doc.to_html
          end

          def iife_bundle_path
            File.join(@dist_dir, "app.iife.js")
          end

          def iife_css_path
            File.join(@dist_dir, "app.css")
          end

          def iife_bundle_exists?
            File.exist?(iife_bundle_path)
          end

          private

          def build_head(doc, title:, head_extra:, script_data:)
            doc.head do
              doc.meta(charset: "UTF-8")
              doc.meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
              doc.title { doc.text title.to_s }
              if script_data
                doc.script { doc.text script_data }
              end
              next unless head_extra && !head_extra.empty?

              doc << Nokogiri::HTML5::DocumentFragment.parse(head_extra)
            end
          end

          def build_body(doc, body_content:, app_mount_id:)
            doc.body do
              if app_mount_id
                doc.div(id: app_mount_id) do
                  doc << Nokogiri::HTML5::DocumentFragment.parse(body_content.to_s)
                end
              else
                doc << Nokogiri::HTML5::DocumentFragment.parse(body_content.to_s)
              end
            end
          end
        end
      end
    end
  end
end
