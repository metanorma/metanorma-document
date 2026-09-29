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
          # Linear scan of the opening tag only: possessive-free two-quantifier
          # regexes over `<svg...` content are polynomial on adversarial input
          # (rb/polynomial-redos), so slice the tag once and edit it literally.
          open_tag = svg[/\A(?:<!--.*?-->\s*)?(?:<\?xml[^?]*\?>\s*)?<svg[^>]*>/m]
          svg = if open_tag
                  if open_tag.include?('height="')
                    svg.sub(open_tag, open_tag.sub(/ height="[^"]*"/,
                                                   %( height="#{height}")))
                  else
                    svg.sub(open_tag, open_tag.sub(/<svg\b/,
                                                   %(<svg height="#{height}" )))
                  end
                else
                  svg.sub(/<svg\s/, '<svg class="header-logo" ')
                end
          if open_tag && open_tag.include?('width="')
            svg = svg.sub(open_tag, open_tag.sub(/ width="[^"]*"/, ""))
          end
        rescue StandardError
          nil
        end
      end
    end
  end
end
