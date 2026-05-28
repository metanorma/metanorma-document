# frozen_string_literal: true

module Metanorma
  module Html
    # Renders OgcDocument components to HTML.
    # Extends IsoRenderer with OGC-specific branding (geospatial, OGC cyan-blue #00b1ff).
    class OgcRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["OGC"]
      end

      def flavor_publisher_name
        "OGC"
      end

      def publisher_logo_map
        { "OGC" => "ogc-logo.svg" }
      end

      def theme
        @theme ||= Theme.load(:ogc)
      end

      # OGC preface: wrap all preface clauses (except ToC) under a "Preface" heading.
      # OGC documents have no foreword/introduction — their preface clauses are
      # security, submitting_orgs, submission contacts, etc.
      def render_preface(preface, **_opts)
        preface_clauses = preface.clause&.reject { |cl| cl.type == "toc" } || []

        return if preface_clauses.empty? &&
          !preface.foreword && !preface.introduction &&
          !preface.abstract && !preface.acknowledgements &&
          !preface.executivesummary

        @output << "<div id=\"preface\" class=\"preface-section\">"
        register_toc_entry(id: "preface", level: 1, text: "Preface")
        @output << "<h1 class=\"foreword-title\">Preface</h1>"

        preface_clauses.each { |cl| render(cl, level: 2) }

        @output << "</div>"
      end
    end
  end
end
