# frozen_string_literal: true

module Metanorma
  module Html
    module Concerns
      # Document metadata extraction from bibdata, mixed into
      # BaseRenderer: page language, HTML title, and the primary document
      # identifier used in the header.
      module MetadataExtraction
        def language
          bibdata = @document.bibdata
          return "en" unless bibdata

          langs = bibdata.language
          if langs && !langs.empty?
            lang = langs.find { |l| l.current == "true" } || langs.first
            lang.value || lang.to_s
          else
            "en"
          end
        end

        def html_title
          extract_display_title(@document.bibdata) || "Document"
        end

        def extract_display_title(bibdata)
          return nil unless bibdata

          title = bibdata.title_for("en") if bibdata.is_a?(Metanorma::Document::Components::BibData::BibData)
          return title.to_s if title && !title.to_s.empty?

          titles = safe_attr(bibdata, :title)
          return nil unless titles && !titles.is_a?(String) && !titles.empty?

          en = titles.find { |t| safe_attr(t, :language) == "en" }
          found = en || titles.first
          extract_text_value(found).to_s
        end

        def extract_primary_doc_id
          bibdata = @document.bibdata
          return nil unless bibdata

          identifiers = bibdata.doc_identifier
          return nil unless identifiers && !identifiers.empty?

          first_id = identifiers.first
          text = if first_id.is_a?(String)
                   first_id
                 elsif first_id.is_a?(Lutaml::Model::Serializable)
                   Array(first_id.value).join
                 else
                   first_id.to_s
                 end
          text.strip.empty? ? nil : text.strip
        end
      end
    end
  end
end
