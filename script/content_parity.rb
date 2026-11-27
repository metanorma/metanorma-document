# frozen_string_literal: true

# Content-parity check between the new metanorma-document HTML renderer and
# the legacy isodoc HTML converter (metanorma/metanorma-document#114).
#
# This is a CONTENT check, not a style check. The legacy output is a content
# reference only: the question asked is "what text and structure present in
# the legacy HTML is absent from the new HTML?". CSS, themes and class names
# are never compared.
#
# For one flavor and one sample document the script
#   1. builds presentation XML (Asciidoctor backend + the flavor's
#      PresentationXMLConvert, or a supplied presentation XML file),
#   2. renders it with legacy isodoc (IsoDoc::<Flavor>::HtmlConvert) and with
#      Metanorma::Html::Generator,
#   3. extracts text blocks, headings and structural elements from both,
#   4. reports what the new output loses.
#
# Usage (needs the flavor gems in the bundle):
#   bundle exec ruby script/content_parity.rb --flavor iso
#   bundle exec ruby script/content_parity.rb --all --out results/parity
#   bundle exec ruby script/content_parity.rb --flavor iso \
#       --xml spec/fixtures/iso/is/document-en.presentation.xml
#
# Output: one JSON file per flavor/case plus losses.md (a per-flavor table).

require "json"
require "nokogiri"
require "optparse"
require "fileutils"
require "open3"

module ContentParity
  DOT_ENTRIES = %w[. ..].freeze

  FLAVORS = %w[bipm cc gb generic iec ieee ietf iho iso itu jis m3aawg ogc
               oiml plateau ribose un nist bsi].freeze

  FIXTURE_DIR = File.expand_path("../spec/fixtures/content-parity", __dir__)

  # Elements whose text is compared as one unit.
  BLOCK_TAGS = %w[p li td th h1 h2 h3 h4 h5 h6 dt dd caption figcaption pre
                  blockquote].freeze

  # Generated navigation is not authored content; it is excluded on both sides.
  CHROME_SELECTOR = "script, style, nav, .TOC, [class*='toc'], [hidden]"

  # Structural kinds. Detection is by tag or by class token because the two
  # renderers use different class names for the same thing. Each kind lists a
  # css selector for the legacy side and for the new side.
  KINDS = {
    "headings" => { both: "h1, h2, h3, h4, h5, h6" },
    "tables" => { both: "table" },
    "figures" => { both: "figure, img" },
    "formulas" => { both: "math" },
    "bullet/ordered lists" => { both: "ul, ol" },
    "list items" => { both: "li" },
    "definition lists" => { both: "dl" },
    "code blocks" => { both: "pre" },
    "quotes" => { legacy: "blockquote, .Quote", new: "blockquote, .quote" },
    "notes" => { legacy: ".Note", new: ".note-block" },
    "examples" => { both: ".example" },
    "terms" => { both: ".TermNum" },
    "footnote refs" => { legacy: ".FootnoteRef", new: ".fn-link" },
    "footnote bodies" => { legacy: ".footnote", new: ".footnote" },
    "bibliography entries" => { legacy: ".NormRef, .Biblio",
                                new: ".biblio-entry" },
    "cross-references" => { both: "a[href^='#']" },
  }.freeze

  module_function

  def normalize(text)
    text.to_s.unicode_normalize(:nfkc).downcase.gsub(/[^[:alnum:]]+/, "")
  end

  def squash(text)
    text.to_s.gsub(/[[:space:]]+/, " ").strip
  end

  # Strip chrome and return the document body as a Nokogiri node.
  def content_body(html)
    body = Nokogiri::HTML(html).at("body") ||
      Nokogiri::HTML("<body></body>").at("body")
    body.css(CHROME_SELECTOR).each(&:remove)
    body
  end

  # Text units: for each block element, its own text with nested blocks
  # removed, so a list item containing a paragraph is not counted twice.
  def text_blocks(body)
    sel = BLOCK_TAGS.join(", ")
    body.css(sel).filter_map do |node|
      copy = node.dup
      copy.css(sel).each(&:remove)
      text = squash(copy.text)
      next if normalize(text).empty?

      { "tag" => node.name, "text" => text }
    end
  end

  def inline_text_without_popups(body)
    copy = body.dup
    copy.css(".fn-popup").each(&:remove)
    copy.text
  end

  def count_kind(body, selector)
    return 0 unless selector

    body.css(selector).size
  end

  def kind_counts(body, side)
    KINDS.transform_values do |sel|
      count_kind(body, sel[side] || sel[:both])
    end
  end

  def link_texts(body)
    body.css("a[href^='#']").map { |a| normalize(a.text) }.reject(&:empty?)
  end

  # Compare two html strings; returns a Hash (JSON-friendly).
  def compare(legacy_html, new_html)
    lbody = content_body(legacy_html)
    nbody = content_body(new_html)
    new_flat = normalize(inline_text_without_popups(nbody))
    new_norm_blocks = text_blocks(nbody).map { |b| normalize(b["text"]) }

    lblocks = text_blocks(lbody)
    missing = lblocks.reject { |b| new_flat.include?(normalize(b["text"])) }
    missing = missing.uniq { |b| normalize(b["text"]) }
    heading_missing = missing.select { |b| b["tag"] =~ /\Ah\d\z/ }

    lcounts = kind_counts(lbody, :legacy)
    ncounts = kind_counts(nbody, :new)
    lost_kinds = KINDS.keys.select { |k| ncounts[k] < lcounts[k] }

    lm = link_texts(lbody).tally
    nm = link_texts(nbody).tally
    lost_links = lm.filter_map { |t, c| [t, c - nm.fetch(t, 0)] if c > nm.fetch(t, 0) }

    {
      "legacy_blocks" => lblocks.size,
      "new_blocks" => new_norm_blocks.size,
      "missing_blocks" => missing,
      "missing_headings" => heading_missing,
      "legacy_counts" => lcounts,
      "new_counts" => ncounts,
      "lost_kinds" => lost_kinds,
      "lost_link_texts" => lost_links.to_h,
    }
  end

  # ---- rendering (needs flavor gems; loaded lazily) ------------------------

  def class_name(flavor)
    flavor.split("-").map(&:capitalize).join
  end

  def presentation_xml(flavor, adoc_path)
    require "asciidoctor"
    require "metanorma-#{flavor}"
    Dir.chdir(File.dirname(adoc_path)) do
      before = Dir.glob(".*", File::FNM_DOTMATCH) + Dir.glob("*")
      begin
        xml = Asciidoctor.convert(File.read(adoc_path), backend: flavor.to_sym,
                                                        safe: :safe,
                                                        header_footer: true)
        ::IsoDoc.const_get(class_name(flavor))::PresentationXMLConvert
          .new({}).convert("sample", xml, true)
      ensure
        # Metanorma drops run artifacts (.xml.abort, .html.err.html, ...)
        # beside the input; remove only what this run created.
        (Dir.glob(".*", File::FNM_DOTMATCH) + Dir.glob("*") - before)
          .each { |f| FileUtils.rm_rf(f) unless DOT_ENTRIES.include?(f) }
      end
    end
  end

  def legacy_html(flavor, pres_xml)
    require "metanorma-#{flavor}"
    ::IsoDoc.const_get(class_name(flavor))::HtmlConvert
      .new({}).convert("sample", pres_xml, true)
  end

  def new_html(flavor, pres_xml)
    require "metanorma/document"
    require "metanorma/html"
    require "metanorma-#{flavor}"
    root = ::Metanorma.const_get(class_name(flavor))::Document::Root
    ::Metanorma::Html::Generator.generate(root.from_xml(pres_xml))
  end

  # Run one case and never raise: failures are data.
  def run_case(flavor, name, adoc: nil, xml: nil)
    result = { "flavor" => flavor, "case" => name }
    stage = "source"
    pres = xml ? File.read(xml) : presentation_xml(flavor, adoc)
    stage = "legacy"
    legacy = legacy_html(flavor, pres)
    stage = "new"
    fresh = new_html(flavor, pres)
    result.merge(compare(legacy, fresh)).merge("status" => "compared")
  rescue StandardError, ScriptError, SystemExit => e
    result.merge("status" => "#{stage}-failed",
                 "error" => "#{e.class}: #{squash(e.message)[0, 160]}")
  end

  def cases_for(flavor)
    cases = Dir[File.join(FIXTURE_DIR, "*.adoc")].map do |f|
      [File.basename(f, ".adoc"), { adoc: f }]
    end
    repo = File.expand_path("..", __dir__)
    extra = {
      "iso" => "spec/fixtures/iso/is/document-en.presentation.xml",
      "itu" => "spec/fixtures/itu/d-rec-d.19-201003/en.presentation.xml",
      "ogc" => "spec/fixtures/ogc/19-004/document.presentation.xml",
    }[flavor]
    if extra
      cases << ["fixture-#{File.basename(extra, '.presentation.xml')}",
                { xml: File.join(repo, extra) }]
    end
    cases
  end

  # ---- reporting -----------------------------------------------------------

  def summary_row(result)
    unless result["status"] == "compared"
      return "| #{result['flavor']} | #{result['case']} | #{result['status']} | " \
             "#{result['error']} |  |  |  |"
    end

    miss = result["missing_blocks"].size
    "| #{result['flavor']} | #{result['case']} | compared | " \
      "#{miss}/#{result['legacy_blocks']} text blocks missing | " \
      "#{result['missing_headings'].size} | " \
      "#{result['lost_kinds'].join(', ')} | " \
      "#{result['lost_link_texts'].size} |"
  end

  def markdown(results, details: 5)
    out = ["# Content losses: new HTML vs legacy isodoc HTML", "",
           "| flavor | case | status | result | headings missing | " \
           "structure counts lower in new | xref texts lost |",
           "|---|---|---|---|---|---|---|"]
    results.each { |r| out << summary_row(r) }
    out << "" << "## Details" << ""
    results.select { |r| r["status"] == "compared" }.each do |r|
      next if r["missing_blocks"].empty? && r["lost_kinds"].empty?

      out << "### #{r['flavor']} / #{r['case']}" << ""
      r["lost_kinds"].each do |k|
        out << "- #{k}: legacy #{r['legacy_counts'][k]}, new #{r['new_counts'][k]}"
      end
      r["missing_blocks"].first(details).each do |b|
        out << "- missing <#{b['tag']}>: #{b['text'][0, 100]}"
      end
      rest = r["missing_blocks"].size - details
      out << "- ... #{rest} more missing blocks (see json)" if rest.positive?
      out << ""
    end
    out.join("\n")
  end

  # ---- CLI ----------------------------------------------------------------

  def main(argv)
    opts = { out: "results/parity" }
    OptionParser.new do |o|
      o.on("--flavor F") { |v| opts[:flavor] = v }
      o.on("--all") { opts[:all] = true }
      o.on("--collect") { opts[:collect] = true }
      o.on("--xml PATH") { |v| opts[:xml] = v }
      o.on("--out DIR") { |v| opts[:out] = v }
    end.parse!(argv)
    FileUtils.mkdir_p(opts[:out])
    return run_all(opts) if opts[:all]
    return collect(opts) if opts[:collect]

    flavor = opts.fetch(:flavor)
    cases = opts[:xml] ? [["custom", { xml: opts[:xml] }]] : cases_for(flavor)
    results = cases.map { |n, src| run_case(flavor, n, **src) }
    File.write(File.join(opts[:out], "#{flavor}.json"),
               JSON.pretty_generate(results))
    puts markdown(results) if opts[:xml] || !opts[:all]
  end

  # Rebuild losses.md from the per-flavor json files in --out.
  def collect(opts)
    all = FLAVORS.flat_map do |f|
      path = File.join(opts[:out], "#{f}.json")
      File.exist?(path) ? JSON.parse(File.read(path)) : []
    end
    File.write(File.join(opts[:out], "losses.md"), markdown(all))
  end

  # One subprocess per flavor so one broken flavor cannot affect the rest.
  def run_all(opts)
    all = FLAVORS.flat_map do |f|
      Open3.capture3("ruby", __FILE__, "--flavor", f, "--out", opts[:out])
      path = File.join(opts[:out], "#{f}.json")
      if File.exist?(path)
        JSON.parse(File.read(path))
      else
        [{ "flavor" => f, "case" => "-", "status" => "process-failed",
           "error" => "no output" }]
      end
    end
    File.write(File.join(opts[:out], "losses.md"), markdown(all))
    puts "wrote #{File.join(opts[:out], 'losses.md')}"
  end
end

ContentParity.main(ARGV) if $PROGRAM_NAME == __FILE__
