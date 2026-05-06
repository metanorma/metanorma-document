# frozen_string_literal: true

module Metanorma
  module Html
    # Renders BipmDocument components to HTML.
    # Extends IsoRenderer with BIPM-specific branding (institutional navy, scientific precision).
    class BipmRenderer < IsoRenderer

      def flavor_publishers(_doc_id)
        ["BIPM"]
      end

      def flavor_publisher_name
        "BIPM"
      end

      def publisher_logo_map
        { "BIPM" => "bipm-logo.svg" }
      end

      # Strip redundant publisher prefix from doc identifiers.
      # XML has "BIPM BIPM-2015/02" but we already show the BIPM logo.
      def clean_doc_id(raw_id)
        raw_id.to_s.gsub(/\ABIPM\s+/, "").strip
      end

      # BIPM logo: white fill for dark header
      def load_logo_svg(filename, **opts)
        svg = super
        svg = svg.gsub(/fill:#0f3c80/, "fill:white") if svg
        svg
      end

      # Strip BIPM prefix from doc IDs shown in header
      def extract_primary_doc_id
        raw = super
        clean_doc_id(raw)
      end

      # Override cover page to show clean doc ID (without redundant "BIPM " prefix)
      def render_coverpage(doc)
        bibdata = doc.bibdata
        return unless bibdata

        @output << "<div class=\"title-section\">"
        @output << "<div class=\"cover-grid\">"
        @output << "<div class=\"cover-meta\">"

        # Publisher logos
        logos = publisher_logos_html(doc)
        if logos && !logos.empty?
          @output << "<div class=\"cover-publishers\">"
          logos.each { |svg| @output << "<span class=\"cover-logo\">#{svg}</span>" }
          @output << "</div>"
        end

        identifiers = Array(bibdata.doc_identifier).compact
        cover_ids = identifiers.select { |di| safe_attr(di, :type) == "iso-reference" }
        cover_ids = [identifiers.first].compact if cover_ids.empty?

        cover_ids.each do |di|
          id = clean_doc_id(extract_text_value(di))
          next if id.to_s.empty?

          @output << "<p class=\"cover-doc-id\">#{escape_html(id)}</p>"
        end

        bibdata.date&.each do |date|
          date_type = extract_text_value(safe_attr(date, :type_attr) || safe_attr(date, :type))
          date_val = extract_text_value(date.is_a?(Metanorma::Document::Relaton::BibliographicDate) ? date.on : safe_attr(date, :text))
          if date_type == "published" && date_val
            @output << "<p class=\"cover-date\">#{escape_html(date_val)}</p>"
          end
        end

        @output << "</div>"
        @output << "<div class=\"cover-body\">"

        title_text = extract_display_title(bibdata)
        if title_text && !title_text.empty?
          @output << "<div class=\"cover-title\"><span>#{escape_html(title_text)}</span></div>"
        end

        if bibdata.status && bibdata.status.stage
          stages = Array(bibdata.status.stage)
          stage_text = stages.map { |s| Array(s.value).join }.join(" ")
          unless stage_text.empty?
            @output << "<div class=\"cover-stage\"><p>#{escape_html(stage_text)}</p></div>"
          end
        end

        @output << "</div>"
        @output << "</div>"
        @output << "</div><hr class=\"cover-separator\" />"
      end

      def theme
        @theme ||= Theme.new.tap do |t|
          t.primary        = "#0f3c80"
          t.accent         = "#3d7ec7"
          t.accent_deep    = "#1a5a9e"
          t.gradient       = "linear-gradient(135deg, #082247 0%, #0f3c80 50%, #1a5a9e 100%)"
          t.primary_light  = "#edf1f7"
          t.accent_light   = "#e8f0fa"
          t.warm           = "#7a6952"
          t.warm_light     = "#f5f0e8"
          t.sidebar_bg     = "#f4f6fa"
          t.font_body      = '"Crimson Pro", "Georgia", "Times New Roman", serif'
          t.font_sans      = '"IBM Plex Sans", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"IBM Plex Mono", "Fira Code", "Courier New", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400&family=IBM+Plex+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400&family=IBM+Plex+Mono:wght@400;500&display=swap"
          t.header_background = "linear-gradient(135deg, #082247 0%, #0f3c80 50%, #1a5a9e 100%)"
          t.cover_background  = "linear-gradient(175deg, #04122a 0%, #0a2e5c 25%, #0f3c80 55%, #1a5a9e 80%, #3d7ec7 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 25% 15%, rgba(61,126,199,0.15) 0%, transparent 50%), radial-gradient(ellipse at 75% 85%, rgba(15,60,128,0.18) 0%, transparent 40%), radial-gradient(circle at 50% 50%, rgba(255,255,255,0.02) 0%, transparent 70%)"
          t.cover_after_bg    = "height: 3px; background: linear-gradient(90deg, transparent, #3d7ec7 20%, #0f3c80 50%, #3d7ec7 80%, transparent)"
          t.progress_bar_color = "#3d7ec7"
          t.note_border     = "#3d7ec7"
          t.note_bg         = "#edf1f7"
          t.note_color      = "#3d7ec7"
          t.example_border  = "#0f3c80"
          t.example_bg      = "#f5f0e8"
          t.example_color   = "#7a6952"
          t.admonition_border = "#7a6952"
          t.admonition_bg   = "#f5f0e8"
          t.admonition_color = "#7a6952"
          t.footer_border_color = "#3d7ec7"
          t.cover_separator_color = "rgba(61,126,199,0.25)"
          t.dark_note_bg    = "#0d1520"
          t.dark_example_bg = "#14100e"
          t.dark_admonition_bg = "#141210"
          t.extra_css = <<~CSS
            .sourcecode pre { background: #0a1628; border-color: #1a2d4a; }
            .reading-progress { box-shadow: 0 0 10px rgba(61,126,199,0.4); }
            mark.search-match { background: #edf1f7; box-shadow: 0 0 0 1px rgba(15,60,128,0.25); }
            mark.search-match.search-current { background: #3d7ec7; color: #fff; }
            [data-theme="dark"] .sourcecode pre { background: #060a14; border-color: #1a2040; }
            [data-theme="dark"] mark.search-match { background: #0d1a30; box-shadow: 0 0 0 1px rgba(61,126,199,0.4); }
            [data-theme="dark"] mark.search-match.search-current { background: #1a5a9e; }
          CSS
        end
      end
    end
  end
end
