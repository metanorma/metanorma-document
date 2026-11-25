# frozen_string_literal: true

require "spec_helper"
require "json"
require "open3"
require "tmpdir"

RSpec.describe "Bundled ISO and IEC HTML body visual parity" do
  before do
    skip "Set HTML_THEME_PARITY=1 after installing frontend Puppeteer/Chromium" unless ENV["HTML_THEME_PARITY"] == "1"

    # Loaded here, not at file load, so the flavour converters never alter
    # global state for the other (always-run) HTML specs.
    require "isodoc/iso/html_convert"
    require "isodoc/iec/html_convert"
    require "isodoc/iec/presentation_xml_convert"
  end

  let(:fixture) { File.expand_path("../../../fixtures/html-theme-parity/document.xml", __dir__) }
  let(:browser_script) { File.expand_path("../../../support/html_theme_parity.mjs", __dir__) }
  let(:properties) do
    %w[font-family font-size font-weight font-style line-height color
       background-color margin-top margin-bottom padding-top padding-bottom letter-spacing]
  end
  let(:probes) do
    {
      "foreword" => "#parity-foreword > :is(h1,h2)",
      "scope" => "#parity-scope > :is(h1,h2)",
      "subclause" => "#parity-subclause > :is(h1,h2,h3)",
      "paragraph" => "#parity-paragraph",
      "detail" => "#parity-detail",
    }.map { |name, selector| { name: name, legacy: selector, theme: selector } }
  end

  def compare(directory, legacy, theme)
    input = { pages: { legacy: legacy, theme: theme }, probes: probes, properties: properties }
    input_path = File.join(directory, "comparison.json")
    File.write(input_path, JSON.generate(input))
    stdout, stderr, status = Open3.capture3("node", browser_script, input_path)
    raise "Browser comparison failed (#{status.exitstatus}): #{stderr}" unless status.success?

    JSON.parse(stdout)
  end

  %w[iso iec].each do |flavor|
    it "matches #{flavor} legacy structure and computed key styles" do
      Dir.mktmpdir("#{flavor}-theme-parity") do |directory|
        xml = File.read(fixture)
        legacy = File.join(directory, "legacy.html")
        theme = File.join(directory, "theme.html")
        IsoDoc.const_get(flavor.capitalize)::HtmlConvert.new({})
          .convert(File.join(directory, "sample.xml"), xml, false, legacy)
        # Use the real flavor renderer in isolation from spec-side registration.
        # Pin the bundled theme: flavor gems may register their own override.
        script = <<~RUBY
          require "metanorma/document"
          require "metanorma/#{flavor}/document"
          require "metanorma/#{flavor}/html"
          flavor = Metanorma.const_get(#{flavor.capitalize.inspect})
          document = flavor::Document::Root.from_xml(File.read(ARGV.fetch(0)))
          theme = Metanorma::Html::Theme.from_yaml(File.read(ARGV.fetch(1)))
          print flavor::Html::Renderer.new.generate_full_document(document, theme: theme)
        RUBY
        lib = File.expand_path("../../../../lib", __dir__)
        theme_path = File.join(Metanorma::Html::Theme::THEMES_DIR, "#{flavor}.yaml")
        html, error, status = Open3.capture3(RbConfig.ruby, "-I", lib, "-e", script, fixture, theme_path)
        expect(status).to be_success, error
        File.write(theme, html)
        result = compare(directory, legacy, theme)
        if ENV["HTML_THEME_PARITY_OUTPUT"]
          output = File.join(ENV.fetch("HTML_THEME_PARITY_OUTPUT"), flavor)
          FileUtils.mkdir_p(output)
          FileUtils.cp([legacy, theme], output)
          File.write(File.join(output, "comparison.json"), JSON.pretty_generate(result))
        end
        expect(result.fetch("mismatches")).to be_empty,
                                              result.fetch("mismatches").join("\n")
      end
    end
  end

  it "detects changed text and computed styles" do
    Dir.mktmpdir("changed-theme-parity") do |directory|
      legacy = File.join(directory, "legacy.html")
      theme = File.join(directory, "theme.html")
      html = '<!doctype html><html><body><p id="parity-paragraph">Original</p></body></html>'
      File.write(legacy, html)
      File.write(theme, html.sub("Original", "Changed").sub("<p ", '<p style="font-size: 20px" '))
      result = compare(directory, legacy, theme)
      differences = result.fetch("mismatches").join("\n")
      expect(differences).to include("paragraph.text:", "paragraph.font-size:")
    end
  end

  it "rejects missing probes rather than passing empty output" do
    Dir.mktmpdir("empty-theme-parity") do |directory|
      file = File.join(directory, "empty.html")
      File.write(file, "<!doctype html><html><body></body></html>")
      result = compare(directory, file, file)
      expect(result.fetch("mismatches").size).to eq(probes.size)
      expect(result.fetch("mismatches").join).to include("expected one element per renderer")
    end
  end
end
