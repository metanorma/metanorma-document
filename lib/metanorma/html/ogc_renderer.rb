# frozen_string_literal: true

module Metanorma
  module Html
    # Renders OgcDocument components to HTML.
    # Extends IsoRenderer with OGC-specific branding (geospatial, OGC cyan-blue #00b1ff).
    class OgcRenderer < IsoRenderer
      registers_doc_type Metanorma::OgcDocument::Root

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
        @theme ||= Theme.new.tap do |t|
          t.primary        = "#0077b3"
          t.accent         = "#00b1ff"
          t.gradient       = "linear-gradient(135deg, #003d5c 0%, #0077b3 50%, #00b1ff 100%)"
          t.accent_deep    = "#006699"
          t.primary_light  = "#e8f4fa"
          t.accent_light   = "#e0f4ff"
          t.warm           = "#e8812e"
          t.warm_light     = "#fff5eb"
          t.sidebar_bg     = "#f2f8fc"
          t.font_body      = '"Space Grotesk", "Helvetica Neue", Arial, sans-serif'
          t.font_sans      = '"Space Grotesk", "Helvetica Neue", Arial, sans-serif'
          t.font_mono      = '"JetBrains Mono", "Fira Code", monospace'
          t.font_url       = "https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap"
          t.header_background = "linear-gradient(135deg, #003d5c 0%, #0077b3 40%, #00b1ff 100%)"
          t.cover_background  = "linear-gradient(175deg, #001f30 0%, #003d5c 25%, #0077b3 55%, #00b1ff 85%, #66d9ff 100%)"
          t.cover_before_bg   = "background: radial-gradient(ellipse at 25% 15%, rgba(0,177,255,0.2) 0%, transparent 45%), radial-gradient(ellipse at 75% 85%, rgba(0,119,179,0.25) 0%, transparent 40%)"
          t.cover_after_bg    = "height: 4px; background: linear-gradient(90deg, transparent, #00b1ff 30%, #0077b3 50%, #00b1ff 70%, transparent)"
          t.progress_bar_color = "#00b1ff"
          t.note_border     = "#00b1ff"
          t.note_bg         = "#e0f4ff"
          t.note_color      = "#0077b3"
          t.example_border  = "#0077b3"
          t.example_bg      = "#e8f4fa"
          t.example_color   = "#004d73"
          t.admonition_border = "#e8812e"
          t.admonition_bg = "#fff5eb"
          t.admonition_color = "#c06a1a"
          t.footer_border_color = "#00b1ff"
          t.cover_separator_color = "rgba(0,177,255,0.25)"
          t.dark_primary_light = "#0a2538"
          t.dark_accent_light  = "#0d2030"
          t.extra_css = <<~CSS
            .sourcecode pre { background: #0a1a28; border-color: #1a3050; }
            .reading-progress { box-shadow: 0 0 10px rgba(0,177,255,0.3); }
            mark.search-match { background: #e0f4ff; box-shadow: 0 0 0 1px rgba(0,177,255,0.3); }
            mark.search-match.search-current { background: #00b1ff; color: #fff; }
            [data-theme="dark"] .sourcecode pre { background: #060e18; border-color: #0d2030; }
          CSS
        end
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
