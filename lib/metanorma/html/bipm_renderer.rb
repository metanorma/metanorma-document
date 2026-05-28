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

        logos = publisher_logos_html(doc)

        identifiers = Array(bibdata.doc_identifier).compact
        cover_ids = identifiers.select do |di|
          safe_attr(di, :type) == "iso-reference"
        end
        cover_ids = [identifiers.first].compact if cover_ids.empty?

        doc_id_texts = cover_ids.filter_map do |di|
          id = clean_doc_id(extract_text_value(di))
          id.to_s.empty? ? nil : escape_html(id)
        end

        date_val = nil
        bibdata.date&.each do |date|
          date_type = extract_text_value(safe_attr(date,
                                                   :type_attr) || safe_attr(
                                                     date, :type
                                                   ))
          raw_date = extract_text_value(date.is_a?(Metanorma::Document::Relaton::BibliographicDate) ? date.on : safe_attr(
            date, :text
          ))
          if date_type == "published" && raw_date
            date_val = escape_html(raw_date)
          end
        end

        title_text = extract_display_title(bibdata)
        stage_text = nil
        if bibdata.status&.stage
          stages = Array(bibdata.status.stage)
          stage_text = stages.map { |s| Array(s.value).join }.join(" ")
          stage_text = nil if stage_text.empty?
        end

        @output << render_liquid("_bipm_cover.html.liquid", {
          "logos" => logos&.any? ? logos : nil,
          "doc_ids" => doc_id_texts,
          "date" => date_val,
          "title" => title_text && !title_text.empty? ? escape_html(title_text) : nil,
          "stage" => stage_text ? escape_html(stage_text) : nil,
        })
      end

      def theme
        @theme ||= Theme.load(:bipm)
      end
    end
  end
end
