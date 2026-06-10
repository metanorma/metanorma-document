# frozen_string_literal: true

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
            data_script = script_data ? %(<script>\n#{script_data}\n</script>) : ""
            mount_point = app_mount_id ? %(<div id="#{app_mount_id}">\n#{body_content}\n</div>) : body_content

            <<~HTML
              <!DOCTYPE html>
              <html lang="en">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>#{title}</title>
                #{data_script}
                #{head_extra}
              </head>
              <body>
                #{mount_point}
              </body>
              </html>
            HTML
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
        end
      end
    end
  end
end
