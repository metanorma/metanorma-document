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
            # Base bibdata carries plain Iso639Code entries (no
            # `current` marker); flavor bibdata models mark one current.
            lang = langs.find { |l| l.respond_to?(:current) && l.current == "true" } ||
              langs.first
            lang.respond_to?(:value) ? (lang.value || lang.to_s) : lang.to_s
          else
            "en"
          end
        end

        def html_title
          extract_display_title(@document.bibdata) || "Document"
        end

        def extract_display_title(bibdata)
          return nil unless bibdata

          title = bibdata.title_for("en") if bibdata.respond_to?(:title_for)
          text = if title.is_a?(Metanorma::Document::Relaton::TypedTitleString)
                   extract_plain_text(title)
                 elsif title
                   title.to_s
                 end
          return text unless text.nil? || text.empty?

          titles = safe_attr(bibdata, :title) || safe_attr(bibdata, :titles)
          titles = safe_attr(titles, :items) || titles
          return nil unless titles && !titles.is_a?(String) && !titles.empty?

          en = titles.find { |t| safe_attr(t, :language) == "en" }
          found = en || titles.first
          extract_text_value(found).to_s
        end

        def extract_primary_doc_id
          bibdata = @document.bibdata
          return nil unless bibdata

          # Flavor bibdata shapes diverge (e.g. IETF carries no ISO-ish
          # doc_identifier): no id rather than a method error.
          identifiers = safe_attr(bibdata, :doc_identifier) ||
            safe_attr(bibdata, :docidentifier)
          return nil unless identifiers && !identifiers.empty?

          first_id = identifiers.first
          text = if first_id.is_a?(String)
                   first_id
                 elsif first_id.is_a?(Lutaml::Model::Serializable)
                   value = safe_attr(first_id, :value) ||
                     safe_attr(first_id, :content) || safe_attr(first_id, :id)
                   Array(value).join
                 else
                   first_id.to_s
                 end
          text.strip.empty? ? nil : text.strip
        end
      end
    end
  end
end
