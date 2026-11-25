# frozen_string_literal: true

require "spec_helper"
require "yaml"
require "digest"
require "tmpdir"
require "fileutils"
require "open3"

module HtmlThemeMatrix
  FIXTURES = File.expand_path("../../../fixtures/html-theme-matrix", __dir__)
  MANIFEST = YAML.safe_load_file(File.join(FIXTURES, "manifest.yaml")).freeze
  ROWS = MANIFEST.fetch("rows").freeze
  RENDER_ROWS = ROWS.select { |_, row| row.key?("theme") }.freeze
  SLOTS = %i[cover_template titlepage_template intro_template].freeze
  STATEMENTS = %w[copyright licence legal feedback].freeze
end

RSpec.describe "HTML flavor/taste theme matrix" do
  let(:fixtures) { HtmlThemeMatrix::FIXTURES }
  let(:manifest) { HtmlThemeMatrix::MANIFEST }
  let(:rows) { HtmlThemeMatrix::ROWS }

  let(:document) do
    Metanorma::Standoc::Document::Root.from_xml(
      File.read(File.join(fixtures, "document.xml")),
    )
  end

  it "renders body content from a real flavor root sharing root attributes" do
    # Flavor register setup must not alter the other model fixtures' state.
    script = <<~RUBY
      require "metanorma/document"
      require "metanorma/cc/document"
      root = Metanorma::Cc::Document::Root.from_xml(File.read(ARGV.fetch(0)))
      abort "Expected an independent flavor root" if root.is_a?(Metanorma::Standoc::Document::Root)
      puts Metanorma::Html::Generator.generate(root, theme: Metanorma::Html::Theme.load(:cc))
    RUBY
    lib = File.expand_path("../../../../lib", __dir__)
    html, error, status = Open3.capture3(RbConfig.ruby, "-I", lib, "-e", script,
                                         File.join(fixtures, "document.xml"))
    expect(status).to be_success, error
    expect(Nokogiri::HTML(html).at_css(".main-section").text)
      .to include("Matrix body content.")
  end

  it "renders typed titles as text in the header and page title" do
    html = Metanorma::Html::Generator.generate(document)
    page = Nokogiri::HTML(html)
    expect(page.at_css("#header-doc-title").text).to eq("Theme matrix")
    expect(page.at_css("head title").text).to eq("Theme matrix — A & B")
  end

  it "keeps the supported back-to-top control without the legacy duplicate" do
    html = Metanorma::Html::Generator.generate(document)
    page = Nokogiri::HTML(html)
    expect(page.css("#back-to-top").size).to eq(1)
    expect(page.css("#myBtn, [onclick*='topFunction']")).to be_empty
  end

  it "uses raw title collection values when grouped titles are unavailable" do
    root = Metanorma::Iso::Document::Root.from_xml(
      File.read(File.join(fixtures, "document.xml")),
    )
    allow(root.bibdata).to receive(:title_for).with("en").and_return(nil)
    title = Metanorma::Html::StandardRenderer.new.extract_display_title(root.bibdata)
    expect(title).to eq("Theme matrix — A & B")
  end

  it "keeps IEC boilerplate catalogue headings out of the sidebar TOC" do
    xml = File.read(File.join(fixtures, "document.xml"))
      .sub("<copyright-statement>", '<copyright-statement><clause id="catalogue"><title>IEC Catalogue</title><p>Catalogue content.</p></clause>')
    root = Metanorma::Standoc::Document::Root.from_xml(xml)
    html = Metanorma::Html::StandardRenderer.new.generate_full_document(root, theme: Metanorma::Html::Theme.load(:iec))
    page = Nokogiri::HTML(html)
    expect(page.at_css(".document-boilerplate").text).to include("IEC Catalogue")
    expect(page.at_css(".toc-sidebar").text).not_to include("IEC Catalogue")
    expect(page.at_css(".toc-sidebar").text).to include("Scope", "Foreword")
  end

  it "classifies every loaded registry entry and every preserved baseline theme" do
    names = Metanorma::Core::Flavors.table.filter_map(&:name).map(&:to_s)
    expect(names - rows.keys).to eq([])
    actual = Dir[File.join(Metanorma::Html::Theme::THEMES_DIR, "*.yaml")]
      .map { |path| File.basename(path, ".yaml") }.sort
    expect(actual).to eq(manifest.fetch("baseline_themes"))
    manifest.fetch("baseline_sha256").each do |name, digest|
      path = File.join(Metanorma::Html::Theme::THEMES_DIR, "#{name}.yaml")
      # Windows checkouts may convert line endings; hash the LF form.
      content = File.binread(path).gsub("\r\n", "\n")
      expect(Digest::SHA256.hexdigest(content)).to eq(digest)
    end
  end

  it "covers every measured model registration and taste, including aliases" do
    registrations = manifest.fetch("source_inventory").values
      .flat_map { |source| source.fetch("model_registrations") }
    expect(registrations - rows.keys).to eq([])
    expect(manifest.fetch("taste_inventory").keys.sort)
      .to eq(rows.select { |_, row| row["kind"] == "taste" }.keys.sort)
    Metanorma::Registry::DEFAULT_ALIASES.each do |name, target|
      expect(rows.fetch(name.to_s).fetch("target")).to eq(target.to_s)
    end
    expect(rows.fetch("csd")).to include("target" => "cc")
    expect(rows.fetch("plateau")).to include("kind" => "flavor")
    expect(rows.fetch("vsd")).to include("kind" => "flavor")
    expect(rows.fetch("mko")).to include("kind" => "infrastructure")
    expect(rows.fetch("snap")).to include("kind" => "infrastructure")
    expect(rows.fetch("en")).to include("kind" => "unknown")
    expect(rows.fetch("mlit")).to include("kind" => "unknown")
  end

  it "requires newly added theme files to have a classified matrix row" do
    names = Dir[File.join(Metanorma::Html::Theme::THEMES_DIR, "*", "theme.yaml")]
      .map { |path| File.basename(File.dirname(path)) }
    expect(names - rows.keys).to eq([])
  end

  HtmlThemeMatrix::RENDER_ROWS.each do |name, row|
    context name do
      let(:theme) { Metanorma::Html::Theme.load(name) }

      it "loads typed config and resolves declared templates and assets" do
        expect(theme.publisher_name).not_to be_nil
        HtmlThemeMatrix::SLOTS.each do |slot|
          template = theme.public_send(slot)
          expect(File.file?(theme.resolve_template(template))).to be(true) if template
        end
        (theme.logos_light.values + theme.logos_dark.values).each do |asset|
          local = theme.resolve_asset(asset)
          shared = File.join(Metanorma::Html::BaseRenderer::LOGO_DIR, asset)
          expect(File.file?(local || shared)).to be(true), "#{name}: missing #{asset}"
        end
        expect(row.fetch("gates")).not_to be_empty
        expect(row.fetch("status")).to eq("parity_pending")
      end

      it "renders the real shared model with its selected composition" do
        # This tests Theme + the B1 hook, not a substitute flavor-owned root.
        renderer = Metanorma::Html::StandardRenderer.new
        html = renderer.generate_full_document(document, theme: theme)
        expect(html).to include("Theme matrix", "A &amp; B", "MATRIX 1:2026", "Matrix body content.")
        HtmlThemeMatrix::STATEMENTS.each do |statement|
          expect(html.scan("Matrix #{statement} statement.").size).to eq(1)
        end
        expect(html.scan("Matrix cover note.").size).to eq(1)
        expect(html).to include(theme.to_css_root)
        expect(html).to include(row["publisher"]) if row["kind"] == "taste"
        if ENV["HTML_THEME_MATRIX_OUTPUT"]
          FileUtils.mkdir_p(ENV.fetch("HTML_THEME_MATRIX_OUTPUT"))
          File.write(File.join(ENV.fetch("HTML_THEME_MATRIX_OUTPUT"), "#{name}.html"), html)
        end
      end
    end
  end

  describe "strict composition" do
    def with_configs(configs)
      Dir.mktmpdir("theme-composition") do |dir|
        configs.each do |name, config|
          path = File.join(dir, "#{name}.yaml")
          File.write(path, config.to_yaml)
        end
        stub_const("Metanorma::Html::Theme::THEMES_DIR", dir)
        yield dir
      end
    end

    it "merges explicit values without injecting child defaults or parent logos" do
      with_configs("parent" => { "primary" => "#112233", "logos_light" => { "Parent" => "logo.svg" } },
                   "child" => { "extends" => "parent", "accent" => "#445566", "logos_light" => {} }) do
        theme = Metanorma::Html::Theme.load(:child)
        expect(theme.primary).to eq("#112233")
        expect(theme.accent).to eq("#445566")
        expect(theme.logos_light).to eq({})
      end
    end

    it "resolves inherited assets and templates with child precedence" do
      with_configs("parent" => {}, "child" => { "extends" => "parent" }) do |dir|
        %w[parent child].each do |name|
          FileUtils.mkdir_p(File.join(dir, name, "templates"))
          File.write(File.join(dir, name, "theme.yaml"),
                     (name == "parent" ? {} : { "extends" => "parent" }).to_yaml)
        end
        File.write(File.join(dir, "parent", "templates", "parent.liquid"), "parent")
        File.write(File.join(dir, "child", "templates", "child.liquid"), "child")
        theme = Metanorma::Html::Theme.load(:child)
        expect(File.read(theme.resolve_template("parent.liquid"))).to eq("parent")
        expect(File.read(theme.resolve_template("child.liquid"))).to eq("child")
        expect { theme.resolve_template("../../../escape") }.to raise_error(ArgumentError)
      end
    end

    it "rejects unknown themes, missing parents, cycles, keys and wrong YAML types" do
      configs = {
        "missing" => { "extends" => "not-installed" },
        "a" => { "extends" => "b" }, "b" => { "extends" => "a" },
        "typo" => { "publiser_name" => "Lost branding" },
        "wrong" => { "publishers" => "Not a collection" },
        "boolean" => { "preface_wrap" => "false" }
      }
      with_configs(configs) do
        %w[unknown missing a typo wrong boolean ../iso].each do |name|
          expect { Metanorma::Html::Theme.load(name) }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe "header_logos" do
    it "renders the header brand with the theme's compact header emblem" do
      Dir.mktmpdir do |dir|
        %w[templates assets].each do |sub|
          FileUtils.mkdir_p(File.join(dir, sub))
        end
        File.write(File.join(dir, "theme.yaml"), {
          "publishers" => ["TEST"],
          "logos_light" => { "TEST" => "test-lockup.svg" },
          "header_logos" => { "TEST" => "test-emblem.svg" },
        }.to_yaml)
        File.write(File.join(dir, "assets", "test-lockup.svg"),
                   '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><circle r="4"/></svg>')
        File.write(File.join(dir, "assets", "test-emblem.svg"),
                   '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><rect width="8" height="8"/></svg>')
        theme = Metanorma::Html::Theme.from_theme_dir(dir)

        html = Metanorma::Html::Generator.generate(document, theme: theme)
        brand = Nokogiri::HTML(html).at_css(".header-brand .brand-logo")
        expect(brand).not_to be_nil
        expect(brand.at_css("svg rect")).not_to be_nil
        expect(brand.at_css("svg circle")).to be_nil
      end
    end
  end
end
