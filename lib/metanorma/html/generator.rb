# frozen_string_literal: true

module Metanorma
  module Html
    # Top-level HTML document generator.
    # Uses a registry pattern for model-to-renderer mapping (open/closed).
    # New flavors register their renderer without modifying existing code.
    #
    # Usage:
    #   doc = Metanorma::IsoDocument::Root.from_xml(File.read("doc.xml"))
    #   html = Metanorma::Html::Generator.generate(doc)
    #   File.write("doc.html", html)
    #
    class Generator
      # Registry: model class => renderer class.
      # Searched in reverse insertion order; subclasses should be registered
      # after their parent classes.
      @renderers = []

      class << self
        def register(model_class, renderer_class)
          @renderers << [model_class, renderer_class]
        end

        def generate(document, **options)
          new(document, **options).generate
        end

        def renderer_for(document)
          @renderers.reverse_each do |model_class, renderer_class|
            return renderer_class if document.is_a?(model_class)
          end
          BaseRenderer
        end
      end

      attr_reader :document, :options, :renderer

      def initialize(document, **options)
        @document = document
        @options = options
        @renderer = self.class.renderer_for(document).new
      end

      def generate
        validate_presentation_xml!

        # First pass: render body content (collects ToC entries as side effect)
        body = body_content
        toc_html = build_toc_html(@renderer.toc_entries)
        header = build_header_bar
        footer = build_footer

        <<~HTML
          <!DOCTYPE html>
          <html lang="#{language}">
          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>#{html_title}</title>
            <link rel="preconnect" href="https://fonts.googleapis.com" />
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
            <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300..700;1,9..40,300..700&family=Source+Serif+4:ital,opsz,wght@0,8..60,300..700;1,8..60,300..700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet" />
            <style>
          #{default_css}
            </style>
          </head>
          <body lang="#{language}">
          #{header}
          <div class="reading-progress" id="reading-progress"></div>
          <div class="doc-layout">
            <aside class="toc-sidebar" id="toc-sidebar">
              <div class="toc-header">
                <h2 class="toc-heading">Contents</h2>
                <button class="toc-close-btn" id="toc-close-btn" aria-label="Close menu">&times;</button>
              </div>
              <nav class="toc-nav">
                <ul class="toc-list">
          #{toc_html}
                </ul>
              </nav>
            </aside>
            <div class="toc-overlay" id="toc-overlay"></div>
            <div class="doc-content" id="doc-content">
          #{body}
            </div>
          #{footer}
          </div>
          <button class="toc-hamburger" id="toc-hamburger" aria-label="Open table of contents">&#9776;</button>
          #{toc_javascript}
          </body>
          </html>
        HTML
      end

      private

      # Presentation XML is required for HTML output — semantic XML lacks
      # formatting data (display titles, autonumbering, boilerplate, etc.)
      def validate_presentation_xml!
        has_presentation = check_presentation_markers(@document)
        return if has_presentation

        raise ArgumentError,
              "HTML generation requires Presentation XML input. " \
              "Semantic XML does not contain formatting data needed for HTML. " \
              "Use a '.presentation.xml' file instead."
      end

      def check_presentation_markers(node)
        return false unless node
        return false if node.is_a?(String)

        # Root element type="presentation" (older-format presentation XML)
        if node.is_a?(Metanorma::Document::Root) && node.type == "presentation"
          return true
        end

        if node.is_a?(Lutaml::Model::Serializable)
          # Presentation markers: fmt_title or displayorder
          return true if (node.public_send(:fmt_title) rescue nil)
          return true if (node.public_send(:displayorder) rescue nil)

          # Recurse into structural children
          %i[preface sections annex bibliography].each do |attr|
            val = node.public_send(attr) rescue nil
            next unless val
            Array(val).each { |v| return true if check_presentation_markers(v) }
          end

          # Recurse into mixed-content children
          node.each_mixed_content do |child|
            next if child.is_a?(String)
            return true if check_presentation_markers(child)
          end
        end

        false
      end

      def language
        bibdata = document.bibdata
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
        bibdata = document.bibdata
        return "Document" unless bibdata

        titles = bibdata.titles
        if titles
          title = bibdata.title_for("en")
          title.to_s
        else
          "Document"
        end
      end

      def body_content
        @renderer.render(@document)
        @renderer.to_html
      end

      # --- ToC generation ---

      def build_toc_html(entries)
        return "<li class=\"toc-empty\">No entries</li>" if entries.empty?

        entries.map { |e|
          id = e[:id].to_s
          text = escape_html(e[:text].to_s)
          lvl = e[:level]
          "<li class=\"toc-level-#{lvl}\"><a href=\"##{id}\" class=\"toc-link\" data-target=\"#{id}\">#{text}</a></li>"
        }.join("\n")
      end

      # --- Header and Footer ---

      LOGO_DIR = File.expand_path("../../../data/logos", __dir__)

      PUBLISHER_LOGOS = {
        "ISO" => "iso-logo.svg",
        "IEC" => "iec-logo.svg",
        "ITU" => "itu-logo.svg",
      }.freeze

      METANORMA_LOGO = "metanorma-logo.svg"

      def build_header_bar
        doc_id = extract_primary_doc_id
        mn_logo = load_logo_svg(METANORMA_LOGO, height: 28)
        pub_logos = publisher_logos
        <<~HTML
          <header class="doc-header">
            <div class="header-brand">
              #{mn_logo ? "<span class=\"header-mn-logo\" aria-label=\"Metanorma\">#{mn_logo}</span>" : "<span class=\"header-mn-mark\">M</span>"}
              <span class="brand-name">Metanorma</span>
              #{pub_logos}
            </div>
            #{"<div class=\"header-doc-id\">#{escape_html(doc_id)}</div>" if doc_id}
          </header>
        HTML
      end

      def publisher_logos
        publishers = detect_publishers
        return "" if publishers.empty?

        publishers.filter_map do |pub|
          svg = load_logo_svg(PUBLISHER_LOGOS[pub], height: 26)
          next unless svg

          "<span class=\"brand-logo\" aria-label=\"#{pub} logo\">#{svg}</span>"
        end.join("\n")
      end

      def detect_publishers
        doc_id = extract_primary_doc_id.to_s
        publishers = []
        publishers << "ISO" if doc_id.match?(/\bISO\b/)
        publishers << "IEC" if doc_id.match?(/\bIEC\b/)
        publishers << "ITU" if doc_id.match?(/\bITU\b/)
        publishers.empty? ? ["ISO"] : publishers
      end

      def load_logo_svg(filename, height: 32)
        path = File.join(LOGO_DIR, filename)
        return nil unless File.exist?(path)

        svg = File.read(path)
        # Remove XML declaration and comments
        svg = svg.sub(/\A<\?xml[^?]*\?>\s*/, "")
        svg = svg.sub(/\A\s*<!--.*?-->\s*/m, "")
        # Remove background fill rect (red for ISO) — header has its own colored background
        svg = svg.sub(/<path[^>]*style="fill:#e3000f[^"]*"[^>]*\/>/, "")
        # Add class
        svg = svg.sub(/<svg\s/, '<svg class="header-logo" ')
        # Set height (replace existing or add new)
        if svg.match?(/<svg[^>]*\sheight="[^"]*"/)
          svg = svg.sub(/(<svg[^>]*?)(\sheight="[^"]*")/, "\\1 height=\"#{height}\"")
        else
          svg = svg.sub(/(<svg\b)/, "\\1 height=\"#{height}\"")
        end
        # Remove fixed width — let SVG scale from viewBox + height
        svg = svg.sub(/(<svg[^>]*?)\swidth="[^"]*"/, '\1')
        svg
      rescue StandardError
        nil
      end

      def build_footer
        mn_logo = load_logo_svg(METANORMA_LOGO, height: 20)
        <<~HTML
          <footer class="doc-footer">
            <div class="footer-brand">
              #{mn_logo ? "<span class=\"footer-mn-logo\">#{mn_logo}</span>" : ""}
              <span class="footer-text">Generated by <strong>Metanorma</strong> &mdash; #{Time.now.strftime('%Y-%m-%d %H:%M')}</span>
            </div>
          </footer>
        HTML
      end

      def extract_primary_doc_id
        bibdata = document.bibdata
        return nil unless bibdata

        identifiers = bibdata.doc_identifier
        return nil unless identifiers && !identifiers.empty?

        first_id = identifiers.first
        text = if first_id.is_a?(String)
                 first_id
               elsif first_id.respond_to?(:value)
                 Array(first_id.value).join
               elsif first_id.respond_to?(:content)
                 Array(first_id.content).join
               elsif first_id.respond_to?(:text)
                 Array(first_id.text).join
               else
                 first_id.to_s
               end
        text.strip.empty? ? nil : text.strip
      end

      def escape_html(text)
        text.to_s
            .gsub("&", "&amp;")
            .gsub("<", "&lt;")
            .gsub(">", "&gt;")
            .gsub('"', "&quot;")
      end

      # --- ToC Interactivity (vanilla JS) ---

      def toc_javascript
        <<~JS
          <script>
          (function() {
            var sidebar = document.getElementById('toc-sidebar');
            var overlay = document.getElementById('toc-overlay');
            var hamburger = document.getElementById('toc-hamburger');
            var closeBtn = document.getElementById('toc-close-btn');
            var progressBar = document.getElementById('reading-progress');

            // --- ToC drawer (mobile) ---
            function openToc() {
              sidebar.classList.add('toc-open');
              overlay.classList.add('toc-overlay-active');
              document.body.style.overflow = 'hidden';
            }
            function closeToc() {
              sidebar.classList.remove('toc-open');
              overlay.classList.remove('toc-overlay-active');
              document.body.style.overflow = '';
            }
            if (hamburger) hamburger.addEventListener('click', openToc);
            if (closeBtn) closeBtn.addEventListener('click', closeToc);
            if (overlay) overlay.addEventListener('click', closeToc);

            // Close on Escape
            document.addEventListener('keydown', function(e) {
              if (e.key === 'Escape' && sidebar.classList.contains('toc-open')) closeToc();
            });

            // --- Reading progress bar ---
            function updateProgress() {
              if (!progressBar) return;
              var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
              var docHeight = document.documentElement.scrollHeight - window.innerHeight;
              var pct = docHeight > 0 ? Math.min((scrollTop / docHeight) * 100, 100) : 0;
              progressBar.style.width = pct + '%';
            }

            // --- ToC active section tracking ---
            var tocLinks = document.querySelectorAll('.toc-link');
            var sections = [];
            tocLinks.forEach(function(link) {
              var target = document.getElementById(link.getAttribute('data-target'));
              if (target) sections.push({ el: target, link: link });
            });

            if (sections.length > 0 && 'IntersectionObserver' in window) {
              var observer = new IntersectionObserver(function(entries) {
                entries.forEach(function(entry) {
                  if (entry.isIntersecting) {
                    tocLinks.forEach(function(l) { l.classList.remove('toc-active'); });
                    var match = sections.find(function(s) { return s.el === entry.target; });
                    if (match) {
                      match.link.classList.add('toc-active');
                      // Scroll ToC sidebar to keep active link visible
                      if (match.link.scrollIntoViewIfNeeded) {
                        match.link.scrollIntoViewIfNeeded(false);
                      }
                    }
                  }
                });
              }, { rootMargin: '-80px 0px -60% 0px' });
              sections.forEach(function(s) { observer.observe(s.el); });
            }

            // Close sidebar on ToC link click (mobile)
            tocLinks.forEach(function(link) {
              link.addEventListener('click', function() {
                if (window.innerWidth < 768) closeToc();
              });
            });

            // Throttled scroll listener for progress bar
            var ticking = false;
            window.addEventListener('scroll', function() {
              if (!ticking) {
                window.requestAnimationFrame(function() {
                  updateProgress();
                  ticking = false;
                });
                ticking = true;
              }
            }, { passive: true });
            updateProgress();
          })();
          </script>
        JS
      end

      # --- CSS ---

      def default_css
        <<~CSS
          /* === 1. Custom Properties (Metanorma Brand) === */
          :root {
            --mn-primary: #28388A;
            --mn-accent: #9C60C1;
            --mn-gradient: linear-gradient(135deg, #28388A 0%, #3a4ba0 50%, #9C60C1 100%);
            --mn-primary-light: #eef0f8;
            --mn-accent-light: #f5eef9;
            --mn-primary-dark: #1c2660;
            --color-text: #1a1a2e;
            --color-text-light: #4a4a6a;
            --color-text-muted: #8888a0;
            --color-bg: #fff;
            --color-bg-light: #fafbff;
            --color-border: #e0e2ee;
            --color-sidebar-bg: #f7f7fc;
            --font-body: "Source Serif 4", "Noto Serif", Georgia, "Times New Roman", serif;
            --font-sans: "DM Sans", "Helvetica Neue", Arial, sans-serif;
            --font-mono: "JetBrains Mono", "Fira Code", "Courier New", monospace;
            --content-max-width: 50em;
            --sidebar-width: 260px;
            --header-height: 52px;
            --radius-sm: 4px;
            --radius-md: 8px;
            --shadow-sm: 0 1px 3px rgba(40,56,138,0.08);
            --shadow-md: 0 4px 12px rgba(40,56,138,0.12);
          }

          /* === 2. Reset & Base === */
          *, *::before, *::after { box-sizing: border-box; margin: 0; }
          html { scroll-behavior: smooth; }
          body {
            font-family: var(--font-body);
            margin: 0;
            padding: 0;
            color: var(--color-text);
            line-height: 1.7;
            background: var(--color-bg);
            -webkit-font-smoothing: antialiased;
            overflow-wrap: break-word;
          }
          h1, h2, h3, h4, h5, h6 {
            font-family: var(--font-sans);
            margin: 1.4em 0 0.5em;
            line-height: 1.3;
            color: var(--mn-primary);
            font-weight: 600;
            scroll-margin-top: calc(var(--header-height) + 12px);
          }
          h1 { font-size: 1.5em; letter-spacing: -0.01em; }
          h2 { font-size: 1.3em; }
          h3 { font-size: 1.15em; }
          h4 { font-size: 1.05em; }
          [id] { scroll-margin-top: calc(var(--header-height) + 12px); }
          p { margin: 0.6em 0; }
          a { color: var(--mn-primary); text-decoration: none; transition: color 0.15s; }
          a:hover { color: var(--mn-accent); text-decoration: underline; }
          img { max-width: 100%; height: auto; }
          ul, ol { margin: 0.5em 0; padding-left: 2em; }
          dl { margin: 0.5em 0; }
          dt { font-weight: bold; margin-top: 0.5em; }
          dd { margin-left: 2em; }
          code { font-family: var(--font-mono); font-size: 0.88em; background: var(--mn-primary-light); padding: 0.1em 0.35em; border-radius: 3px; }
          pre code { background: transparent; padding: 0; }
          blockquote { border-left: 3px solid var(--mn-accent); margin: 1em 0; padding-left: 1em; color: var(--color-text-light); }
          tt { font-family: var(--font-mono); font-size: 0.88em; }

          /* === 3. Reading Progress Bar === */
          .reading-progress {
            position: fixed;
            top: var(--header-height);
            left: 0;
            width: 0%;
            height: 3px;
            background: var(--mn-gradient);
            z-index: 200;
            transition: width 0.1s linear;
          }

          /* === 4. Header Bar === */
          .doc-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            height: var(--header-height);
            padding: 0 1.2em;
            background: var(--mn-gradient);
            color: #fff;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 2px 12px rgba(40,56,138,0.18);
          }
          .header-brand {
            display: flex;
            align-items: center;
            gap: 0.6em;
            min-width: 0;
          }
          .header-mn-logo { display: inline-flex; align-items: center; flex-shrink: 0; }
          .header-mn-logo svg path { fill: #fff; }
          .header-mn-mark {
            display: inline-flex; align-items: center; justify-content: center;
            width: 28px; height: 28px; border-radius: 6px;
            background: rgba(255,255,255,0.2); font-weight: 700;
            font-size: 0.9em; font-family: var(--font-sans);
          }
          .brand-name {
            font-family: var(--font-sans); font-size: 1em; font-weight: 600;
            letter-spacing: 0.01em; opacity: 0.95; white-space: nowrap;
          }
          .brand-logo {
            display: inline-flex; align-items: center; justify-content: center;
            height: 26px; border-radius: var(--radius-sm); overflow: hidden;
            margin-left: 0.4em; background: rgba(255,255,255,0.12);
            padding: 0 0.3em; flex-shrink: 0;
          }
          .brand-logo svg { height: 22px; width: auto; max-width: none; }
          .brand-logo svg path { fill: #fff; }
          .brand-logo + .brand-logo { margin-left: 0.2em; }
          .header-doc-id {
            font-family: var(--font-sans); font-size: 0.82em; opacity: 0.85;
            font-weight: 500; letter-spacing: 0.02em;
            white-space: nowrap; flex-shrink: 0;
          }

          /* === 5. Layout — CSS Grid, mobile-first === */
          .doc-layout {
            display: grid;
            grid-template-columns: 1fr;
            grid-template-rows: auto 1fr auto;
            min-height: calc(100vh - var(--header-height));
          }
          /* On mobile, sidebar & overlay are position:fixed — keep them in grid
             but they don't affect layout since they're out of normal flow.
             doc-content fills the single column. Footer is row 3. */
          .toc-sidebar  { grid-column: 1; grid-row: 1 / 3; }
          .toc-overlay  { grid-column: 1; grid-row: 1 / 3; }
          .doc-content  { grid-column: 1; grid-row: 1; }
          .doc-footer   { grid-column: 1; grid-row: 3; }

          .doc-content {
            padding: 1.2em;
            max-width: var(--content-max-width);
            width: 100%;
            margin: 0 auto;
            overflow-wrap: break-word;
            min-width: 0;
          }

          /* === 6. ToC Sidebar — mobile drawer === */
          .toc-sidebar {
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0;
            left: 0;
            width: min(300px, 85vw);
            height: 100vh;
            height: 100dvh;
            background: var(--color-bg);
            z-index: 1000;
            overflow-y: auto;
            overscroll-behavior: contain;
            box-shadow: var(--shadow-md);
            transform: translateX(-100%);
            transition: transform 0.28s cubic-bezier(0.4, 0, 0.2, 1);
            will-change: transform;
          }
          .toc-sidebar.toc-open {
            transform: translateX(0);
            box-shadow: 4px 0 24px rgba(40,56,138,0.15);
          }
          .toc-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 0.8em 1.2em;
            background: var(--mn-primary-light);
            border-bottom: 1px solid var(--color-border);
            position: sticky; top: 0; z-index: 1;
          }
          .toc-heading {
            font-family: var(--font-sans); font-size: 0.85em; margin: 0;
            text-transform: uppercase; letter-spacing: 0.08em;
            color: var(--mn-primary); font-weight: 600;
          }
          .toc-close-btn {
            background: none; border: none; font-size: 1.3em; cursor: pointer;
            color: var(--color-text-muted); padding: 0 0.2em; line-height: 1;
            transition: color 0.15s;
          }
          .toc-close-btn:hover { color: var(--mn-primary); }
          .toc-nav { flex: 1; overflow-y: auto; padding: 0.5em 0; }
          .toc-list { list-style: none; padding: 0; margin: 0; }
          .toc-list li { margin: 0; }
          .toc-link {
            display: block; padding: 0.35em 1.2em;
            color: var(--color-text-light); font-size: 0.88em;
            font-family: var(--font-sans);
            border-left: 3px solid transparent;
            text-decoration: none; transition: all 0.15s;
          }
          .toc-link:hover {
            background: var(--mn-primary-light);
            border-left-color: var(--mn-accent);
            color: var(--mn-primary);
            text-decoration: none;
          }
          .toc-link.toc-active {
            background: var(--mn-accent-light);
            border-left-color: var(--mn-accent);
            color: var(--mn-primary);
            font-weight: 500;
          }
          .toc-level-1 > .toc-link { font-weight: 600; color: var(--color-text); font-size: 0.9em; }
          .toc-level-2 > .toc-link { padding-left: 1.8em; }
          .toc-level-3 > .toc-link { padding-left: 2.6em; font-size: 0.84em; }
          .toc-level-4 > .toc-link { padding-left: 3.4em; font-size: 0.84em; }
          .toc-empty { color: var(--color-text-muted); font-style: italic; padding: 0.8em 1.2em; font-size: 0.9em; }

          /* Hamburger button (mobile) */
          .toc-hamburger {
            display: flex; align-items: center; justify-content: center;
            position: fixed; bottom: 1.2em; right: 1.2em;
            width: 52px; height: 52px;
            background: var(--mn-gradient); color: #fff;
            border: none; border-radius: 50%; font-size: 1.3em; cursor: pointer;
            box-shadow: 0 3px 14px rgba(40,56,138,0.3);
            z-index: 90;
            transition: transform 0.15s, box-shadow 0.15s;
          }
          .toc-hamburger:hover { transform: scale(1.08); box-shadow: 0 4px 18px rgba(40,56,138,0.4); }
          .toc-hamburger:active { transform: scale(0.96); }

          /* Overlay */
          .toc-overlay {
            position: fixed; inset: 0;
            background: rgba(26,26,46,0.35);
            backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px);
            z-index: 999; opacity: 0; pointer-events: none;
            transition: opacity 0.28s cubic-bezier(0.4, 0, 0.2, 1);
          }
          .toc-overlay-active { opacity: 1; pointer-events: auto; }

          /* === 7. Cover Page === */
          .title-section {
            text-align: center;
            padding: 3em 1.5em 2.5em;
            background: var(--mn-gradient);
            color: #fff;
            margin-bottom: 0;
            position: relative;
            overflow: hidden;
          }
          .title-section::after {
            content: ""; position: absolute;
            bottom: -1px; left: 0; right: 0; height: 40px;
            background: var(--color-bg);
            clip-path: ellipse(55% 100% at 50% 100%);
          }
          .coverpage_docnumber {
            font-family: var(--font-sans); font-weight: 700;
            margin: 0.2em 0; font-size: 1.1em;
            letter-spacing: 0.03em; color: #fff;
            overflow-wrap: break-word;
          }
          .coverpage_docnumber + .coverpage_docnumber {
            font-weight: 400; font-size: 0.88em; opacity: 0.8;
          }
          .doctitle-en {
            font-family: var(--font-sans); font-size: 1.5em;
            margin: 0.6em 0; font-weight: 500;
            color: #fff; line-height: 1.3;
            overflow-wrap: break-word;
          }
          .doctitle-en .subtitle { color: #fff; }
          .coverpage_docstage { margin: 1.2em 0 0; position: relative; z-index: 1; }
          .coverpage_docstage p {
            font-family: var(--font-sans);
            background: rgba(255,255,255,0.18); color: #fff;
            display: inline-block; padding: 0.25em 1.2em;
            border-radius: 20px; font-size: 0.82em; font-weight: 500;
            text-transform: uppercase; letter-spacing: 0.06em;
            border: 1px solid rgba(255,255,255,0.25);
            backdrop-filter: blur(4px);
          }
          .cover-separator {
            border: none; height: 1px;
            background: rgba(255,255,255,0.3);
            margin: 1.8em auto 0; width: 50%;
          }

          .prefatory-section { font-size: 0.92em; color: var(--color-text-light); padding: 0 0.5em; }
          .boilerplate-copyright { font-size: 0.9em; }
          .zzSTDTitle1 {
            text-align: center; font-family: var(--font-sans);
            font-weight: 600; font-size: 1.3em;
            margin: 2em 0 1.5em; color: var(--mn-primary);
          }

          /* === 8. Section Headings === */
          .ForewordTitle, .IntroTitle {
            font-family: var(--font-sans); font-size: 1.4em; font-weight: 600;
            padding-bottom: 0.4em;
            border-bottom: 2px solid var(--mn-accent);
            color: var(--mn-primary);
          }
          .Annex {
            font-family: var(--font-sans); font-weight: 600;
            font-size: 1.2em; line-height: 1.4; color: var(--mn-primary);
          }
          .Section3 { margin-top: 2em; }

          /* === 9. Block Elements === */
          /* Tables: scrollable wrapper via display:block + overflow-x:auto */
          .doc-content table {
            border-collapse: collapse;
            margin: 1em 0;
            font-size: 0.92em;
            box-shadow: var(--shadow-sm);
            display: block;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            max-width: 100%;
          }
          .doc-content tbody { display: table; width: 100%; }
          th, td {
            border: 1px solid var(--color-border);
            padding: 0.55em 0.75em; text-align: left;
            overflow-wrap: break-word; word-break: break-word;
          }
          th {
            background: var(--mn-primary); color: #fff;
            font-family: var(--font-sans); font-weight: 600; font-size: 0.92em;
          }
          tr:nth-child(even) td { background: var(--color-bg-light); }
          tr:hover td { background: var(--mn-primary-light); }

          figure { margin: 1.2em 0; max-width: 100%; }
          figcaption { font-style: italic; font-size: 0.9em; margin-top: 0.3em; color: var(--color-text-light); }

          .Note {
            background: linear-gradient(135deg, #fefef8 0%, #f8f8f2 100%);
            border-left: 3px solid var(--mn-accent);
            padding: 0.8em 1em; margin: 1em 0;
            border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
          }
          .note_label, .termnote_label { font-weight: 600; color: var(--mn-primary); font-family: var(--font-sans); }

          .example {
            background: linear-gradient(135deg, var(--mn-accent-light) 0%, #f0eaf8 100%);
            border-left: 3px solid var(--mn-accent);
            padding: 0.8em 1em; margin: 1em 0;
            border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
          }
          .example_label { font-weight: 600; color: var(--mn-accent); font-family: var(--font-sans); }

          .sourcecode { margin: 1em 0; max-width: 100%; overflow: hidden; }
          .sourcecode pre {
            background: #151528; color: #d4d4e8;
            border: 1px solid #2a2a48; border-radius: var(--radius-md);
            padding: 1em 1.2em; overflow-x: auto;
            font-size: 0.88em; line-height: 1.55;
            max-width: 100%;
            -webkit-overflow-scrolling: touch;
          }
          .sourcecode-name { font-weight: 600; margin-bottom: 0.3em; font-family: var(--font-sans); }

          .formula { margin: 1em 0; text-align: center; overflow-x: auto; }
          .formula .stem { font-style: italic; font-size: 1.05em; }
          .quote { margin: 1em 0; }

          .admonition {
            border-left: 4px solid #e8a820;
            padding: 0.8em 1em; margin: 1em 0;
            background: linear-gradient(135deg, #fffdf5 0%, #fff8e8 100%);
            border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
          }
          .admonition-title { font-weight: 600; margin-bottom: 0.5em; color: #b8860b; font-family: var(--font-sans); }

          /* === 10. Terms === */
          .TermNum {
            font-family: var(--font-sans); font-weight: 700;
            color: var(--mn-primary); margin: 1.4em 0 0.2em; font-size: 0.95em;
          }
          .Terms { font-weight: 600; font-size: 1.02em; }
          .Terms dfn { font-style: normal; }
          .DeprecatedTerms { text-decoration: line-through; color: var(--color-text-muted); }
          .domain { font-style: italic; color: var(--mn-accent); font-size: 0.92em; }

          /* === 11. Bibliography === */
          .Biblio {
            margin: 0.7em 0; padding-left: 2em; text-indent: -2em;
            font-size: 0.93em; line-height: 1.65;
          }
          .stddocNumber { font-weight: 600; color: var(--mn-primary); font-family: var(--font-sans); }
          .stdyear { font-weight: 500; }

          /* === 12. Inline === */
          .footnote { vertical-align: super; font-size: 0.8em; }
          .smallcap { font-variant: small-caps; }
          .obligation { font-style: italic; color: var(--mn-accent); }

          /* === 13. Footer === */
          .doc-footer {
            text-align: center; padding: 1.8em 1em;
            font-size: 0.82em; color: var(--color-text-muted);
            border-top: 1px solid var(--color-border);
            margin-top: 3em; background: var(--color-bg-light);
          }
          .footer-brand {
            display: flex; align-items: center; justify-content: center;
            gap: 0.5em; flex-wrap: wrap;
          }
          .footer-mn-logo svg path { fill: var(--color-text-muted); }
          .footer-text { font-family: var(--font-sans); }
          .doc-footer p { margin: 0.3em 0; }

          /* === 14. Responsive: Desktop (two-column via CSS Grid) === */
          @media (min-width: 768px) {
            .doc-layout {
              grid-template-columns: var(--sidebar-width) minmax(0, 1fr);
              grid-template-rows: 1fr auto;
            }
            .toc-sidebar {
              grid-column: 1; grid-row: 1;
              transform: none;
              position: sticky;
              top: var(--header-height);
              width: var(--sidebar-width);
              height: calc(100vh - var(--header-height));
              height: calc(100dvh - var(--header-height));
              box-shadow: none;
              background: var(--color-sidebar-bg);
              border-right: 1px solid var(--color-border);
              overflow-y: auto;
            }
            .toc-sidebar.toc-open { transform: none; box-shadow: none; }
            .toc-overlay { display: none !important; grid-column: 1; grid-row: 1; }
            .doc-content {
              grid-column: 2; grid-row: 1;
              padding: 2em 2.5em;
              max-width: var(--content-max-width);
            }
            .doc-footer {
              grid-column: 2; grid-row: 2;
            }
            .toc-header {
              background: var(--color-sidebar-bg);
              border-bottom: 1px solid var(--color-border);
            }
            .toc-close-btn { display: none; }
            .toc-hamburger { display: none; }
          }

          @media (min-width: 1024px) {
            :root {
              --sidebar-width: 280px;
              --content-max-width: 54em;
            }
            .toc-link { font-size: 0.9em; }
          }

          /* === 15. Print === */
          @media print {
            .toc-sidebar, .doc-header, .toc-hamburger, .toc-overlay, .doc-footer, .reading-progress {
              display: none !important;
            }
            .doc-layout { display: block; }
            .doc-content { max-width: 100%; padding: 0; }
            .title-section { background: none; color: #000; padding: 1em 0; }
            .title-section::after { display: none; }
            .coverpage_docnumber, .doctitle-en { color: #000; }
            .coverpage_docstage p { background: none; color: #000; border: 1px solid #999; }
            body { font-size: 11pt; color: #000; }
            a { color: #000; text-decoration: underline; }
            .Note { background: none; border-left-color: #999; }
            .sourcecode pre { background: #f5f5f5; color: #000; border-color: #ddd; max-width: none; }
            table { display: table; max-width: none; }
            th { background: #f0f0f0; color: #000; }
          }
        CSS
      end
    end
  end
end

# Register renderers for each document model (most general first, most specific last)
# The registry searches in reverse order, so the most specific match is found first.
Metanorma::Html::Generator.register(Metanorma::Document::Root, Metanorma::Html::BaseRenderer)
Metanorma::Html::Generator.register(Metanorma::StandardDocument::Root, Metanorma::Html::StandardRenderer)
Metanorma::Html::Generator.register(Metanorma::IsoDocument::Root, Metanorma::Html::IsoRenderer)
