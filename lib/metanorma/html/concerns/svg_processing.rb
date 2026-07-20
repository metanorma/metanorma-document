# frozen_string_literal: true

module Metanorma
  module Html
    module Concerns
      # SVG logo loading and normalization mixed into BaseRenderer.
      # Logos ship as standalone SVG files; for inline embedding the xml
      # prolog and leading comments are stripped, a CSS class is added,
      # and width/height are normalized to the requested display height.
      module SvgProcessing
        def load_logo_svg(filename, height: 32)
          path = theme.resolve_asset(filename) || File.join(BaseRenderer::LOGO_DIR, filename)
          return nil unless File.exist?(path)

          svg = File.read(path)
          svg = svg.sub(/\A<\?xml[^?]*\?>\s*/, "")
          svg = svg.sub(/\A\s*<!--.*?-->\s*/m, "")
          svg = svg.sub(/<svg\s/, '<svg class="header-logo" ')
          svg = if svg.match?(/<svg[^>]*\sheight="[^"]*"/)
                  svg.sub(/(<svg[^>]*?)(\sheight="[^"]*")/,
                          "\\1 height=\"#{height}\"")
                else
                  svg.sub(/(<svg\b)/, "\\1 height=\"#{height}\"")
                end
          svg.sub(/(<svg[^>]*?)\swidth="[^"]*"/, '\1')
        rescue StandardError
          nil
        end
      end
    end
  end
end
