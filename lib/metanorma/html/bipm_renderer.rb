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
        svg = svg.gsub("fill:#0f3c80", "fill:white") if svg
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
          logos.each do |svg|
            @output << "<span class=\"cover-logo\">#{svg}</span>"
          end
          @output << "</div>"
        end

        identifiers = Array(bibdata.doc_identifier).compact
        cover_ids = identifiers.select do |di|
          safe_attr(di, :type) == "iso-reference"
        end
        cover_ids = [identifiers.first].compact if cover_ids.empty?

        cover_ids.each do |di|
          id = clean_doc_id(extract_text_value(di))
          next if id.to_s.empty?

          @output << "<p class=\"cover-doc-id\">#{escape_html(id)}</p>"
        end

        bibdata.date&.each do |date|
          date_type = extract_text_value(safe_attr(date,
                                                   :type_attr) || safe_attr(
                                                     date, :type
                                                   ))
          date_val = extract_text_value(date.is_a?(Metanorma::Document::Relaton::BibliographicDate) ? date.on : safe_attr(
            date, :text
          ))
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

        if bibdata.status&.stage
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
        @theme ||= Theme.load(:bipm)
      end
    end
  end
end
