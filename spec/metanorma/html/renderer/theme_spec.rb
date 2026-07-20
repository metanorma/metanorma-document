# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/theme"
require "fileutils"
require "tmpdir"

RSpec.describe Metanorma::Html::Theme do
  subject(:theme) { described_class.new }

  describe "defaults" do
    it "has a primary color" do
      expect(theme.primary).to eq("#28388A")
    end

    it "has accent color" do
      expect(theme.accent).to eq("#9C60C1")
    end

    it "has font stacks" do
      expect(theme.font_body).to include("serif")
      expect(theme.font_sans).to include("sans-serif")
      expect(theme.font_mono).to include("monospace")
    end

    it "has block element defaults" do
      expect(theme.note_border).not_to be_nil
      expect(theme.example_border).not_to be_nil
      expect(theme.admonition_border).not_to be_nil
    end

    it "has empty publishers by default" do
      expect(theme.publishers).to eq([])
    end

    it "has nil publisher_name by default" do
      expect(theme.publisher_name).to be_nil
    end

    it "has empty logos by default" do
      expect(theme.logos).to eq({})
    end
  end

  describe ".load" do
    context "with unknown flavor" do
      it "returns default theme" do
        t = described_class.load(:nonexistent)
        expect(t.primary).to eq("#28388A")
      end
    end

    %i[iso iec ieee ietf itu iho ogc bipm cc icc oiml ribose
       pdfa].each do |flavor|
      context "#{flavor} flavor" do
        let(:theme) { described_class.load(flavor) }

        it "loads without error" do
          expect(theme).not_to be_nil
        end

        it "has a primary color" do
          expect(theme.primary).not_to be_nil
        end

        it "has an accent color" do
          expect(theme.accent).not_to be_nil
        end

        it "has fonts" do
          expect(theme.font_body).not_to be_nil
          expect(theme.font_sans).not_to be_nil
          expect(theme.font_mono).not_to be_nil
        end
      end
    end

    context "ISO theme" do
      let(:theme) { described_class.load(:iso) }

      it "has red primary color" do
        expect(theme.primary).to eq("#b3000c")
      end

      it "has publisher metadata" do
        expect(theme.publishers).to include("ISO")
      end

      it "has publisher_name" do
        expect(theme.publisher_name).to eq("ISO")
      end

      it "has logo map" do
        expect(theme.logos).to include("ISO")
      end
    end

    context "IEC theme" do
      let(:theme) { described_class.load(:iec) }

      it "has publisher metadata" do
        expect(theme.publishers).to include("IEC")
      end
    end

    context "BIPM theme" do
      let(:theme) { described_class.load(:bipm) }

      it "has publisher metadata" do
        expect(theme.publishers).to include("BIPM")
      end
    end
  end

  describe "#to_css_root" do
    let(:css) { theme.to_css_root }

    it "emits :root CSS block" do
      expect(css).to include(":root {")
    end

    it "includes primary color variable" do
      expect(css).to include("--mn-primary: #28388A")
    end

    it "includes accent color variable" do
      expect(css).to include("--mn-accent: #9C60C1")
    end

    it "includes font variables" do
      expect(css).to include("--font-body:")
      expect(css).to include("--font-sans:")
      expect(css).to include("--font-mono:")
    end

    it "includes block element variables" do
      expect(css).to include("--note-bg:")
      expect(css).to include("--example-border:")
      expect(css).to include("--admonition-color:")
    end

    it "includes dark mode overrides" do
      expect(css).to include('[data-theme="dark"]')
      expect(css).to include("--color-bg: #0f1118")
    end

    it "omits header_background when nil" do
      theme.header_background = nil
      expect(css).not_to include("--mn-header-bg")
    end

    it "includes header_background when set" do
      theme.header_background = "linear-gradient(red, blue)"
      expect(css).to include("--mn-header-bg: linear-gradient(red, blue)")
    end
  end

  describe "#to_css_extras" do
    it "returns empty string when no extras set" do
      expect(theme.to_css_extras.strip).to be_empty
    end

    it "includes cover_before_bg when set" do
      theme.cover_before_bg = "background: red"
      expect(theme.to_css_extras).to include("title-section::before")
    end

    it "includes extra_css when set" do
      theme.extra_css = ".foo { color: red }"
      expect(theme.to_css_extras).to include(".foo { color: red }")
    end
  end

  describe "overriding in subclass" do
    it "allows changing colors" do
      t = described_class.new
      t.primary = "#ff0000"
      expect(t.primary).to eq("#ff0000")
    end
  end

  describe "section ordering defaults" do
    it "has default preface_order" do
      expect(theme.preface_order).to eq(%w[foreword introduction abstract clause
                                           acknowledgements executivesummary])
    end

    it "has default clause_order" do
      expect(theme.clause_order).to eq(%w[sections annex bibliography indexsect])
    end

    it "has preface_wrap false by default" do
      expect(theme.preface_wrap).to be(false)
    end

    it "has empty toc_filter_types by default" do
      expect(theme.toc_filter_types).to eq([])
    end
  end

  describe "OGC theme overrides" do
    let(:theme) { described_class.load(:ogc) }

    it "has clause-only preface_order" do
      expect(theme.preface_order).to eq(%w[clause])
    end

    it "has preface_wrap enabled" do
      expect(theme.preface_wrap).to be(true)
    end

    it "filters toc clause types" do
      expect(theme.toc_filter_types).to eq(%w[toc])
    end

    it "has nil theme_dir when loaded from flat file" do
      expect(theme.theme_dir).to be_nil
    end
  end

  describe "directory-based theme loading" do
    let(:tmpdir) do
      File.join(Dir.tmpdir, "metanorma_theme_test_#{Process.pid}")
    end
    let(:theme) do
      stub_const("Metanorma::Html::Theme::THEMES_DIR", tmpdir)
      described_class.load(:testflavor)
    end

    before do
      FileUtils.mkdir_p(File.join(tmpdir, "testflavor", "templates"))
      FileUtils.mkdir_p(File.join(tmpdir, "testflavor", "assets"))
      File.write(File.join(tmpdir, "testflavor", "theme.yaml"), {
        "primary" => "#ff0000",
        "accent" => "#00ff00",
        "publishers" => ["TEST"],
        "publisher_name" => "TestPub",
        "logos" => { "TEST" => "test-logo.svg" },
        "preface_order" => ["introduction", "clause"],
        "preface_wrap" => true,
      }.to_yaml)
      File.write(File.join(tmpdir, "testflavor", "templates", "_custom.html.liquid"),
                 "<div>{{ content }}</div>")
      File.write(File.join(tmpdir, "testflavor", "assets", "test-logo.svg"),
                 '<svg xmlns="http://www.w3.org/2000/svg"><circle r="10"/></svg>')
      File.write(File.join(tmpdir, "testflavor", "custom.css"),
                 ".custom { color: red; }")
    end

    after do
      FileUtils.rm_rf(tmpdir)
    end

    it "loads from directory" do
      expect(theme).not_to be_nil
    end

    it "reads config from theme.yaml" do
      expect(theme.primary).to eq("#ff0000")
    end

    it "sets theme_dir to the flavor directory" do
      expect(theme.theme_dir).to eq(File.join(tmpdir, "testflavor"))
    end

    it "exposes theme_templates_dir" do
      expect(theme.theme_templates_dir).to eq(File.join(tmpdir, "testflavor",
                                                        "templates"))
    end

    it "exposes theme_assets_dir" do
      expect(theme.theme_assets_dir).to eq(File.join(tmpdir, "testflavor",
                                                     "assets"))
    end

    it "exposes theme_css_path" do
      expect(theme.theme_css_path).to eq(File.join(tmpdir, "testflavor",
                                                   "custom.css"))
    end

    it "resolves flavor-specific template" do
      path = theme.resolve_template("_custom.html.liquid")
      expect(path).to eq(File.join(tmpdir, "testflavor", "templates",
                                   "_custom.html.liquid"))
    end

    it "falls back to shared templates for unknown template" do
      path = theme.resolve_template("_nonexistent.html.liquid")
      expect(path).to include("templates")
    end

    it "resolves flavor-specific asset" do
      path = theme.resolve_asset("test-logo.svg")
      expect(path).to eq(File.join(tmpdir, "testflavor", "assets", "test-logo.svg"))
    end

    it "returns nil for missing asset" do
      expect(theme.resolve_asset("nonexistent.svg")).to be_nil
    end

    it "loads publisher metadata from directory theme" do
      expect(theme.publishers).to eq(["TEST"])
      expect(theme.publisher_name).to eq("TestPub")
    end

    it "loads section ordering from directory theme" do
      expect(theme.preface_order).to eq(%w[introduction clause])
      expect(theme.preface_wrap).to be(true)
    end
  end

  describe "flat file fallback" do
    it "still loads flat YAML themes" do
      theme = described_class.load(:iso)
      expect(theme).not_to be_nil
      expect(theme.theme_dir).to be_nil
    end

    it "returns default theme for unknown flavor" do
      theme = described_class.load(:nonexistent)
      expect(theme.primary).to eq("#28388A")
      expect(theme.theme_dir).to be_nil
    end
  end

  describe "template resolution without theme_dir" do
    let(:theme) { described_class.new }

    it "returns shared template path" do
      path = theme.resolve_template("_note.html.liquid")
      expect(path).to include("templates")
    end

    it "returns nil for asset resolution" do
      expect(theme.resolve_asset("logo.svg")).to be_nil
    end

    it "returns nil for css path" do
      expect(theme.theme_css_path).to be_nil
    end
  end

  describe "lutaml-model schema" do
    it "is a Lutaml::Model::Serializable" do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end

    it "has 68 typed attributes" do
      expect(described_class.attributes.size).to eq(68)
    end

    it "has boolean type for preface_wrap" do
      attr = described_class.attributes[:preface_wrap]
      expect(attr).not_to be_nil
      expect(attr.type).to eq(Lutaml::Model::Type::Boolean)
    end

    it "has collection flag on array attributes" do
      %i[publishers preface_order clause_order
         toc_filter_types].each do |name|
        expect(described_class.attributes[name].collection?).to be(true)
      end
    end

    it "has hash type for logos" do
      attr = described_class.attributes[:logos_light]
      expect(attr.type).to eq(Lutaml::Model::Type::Hash)
    end

    it "has string type for color attributes" do
      %i[primary accent note_bg dark_border].each do |name|
        expect(described_class.attributes[name].type).to eq(Lutaml::Model::Type::String)
      end
    end

    it "loads from YAML via lutaml-model" do
      yaml = <<~YAML
        primary: "#b3000c"
        accent: "#ff6600"
        publishers:
          - ISO
        logos_light:
          ISO: iso-logo.svg
        preface_wrap: true
        toc_filter_types:
          - toc
      YAML
      theme = described_class.from_yaml(yaml)
      expect(theme.primary).to eq("#b3000c")
      expect(theme.accent).to eq("#ff6600")
      expect(theme.publishers).to eq(["ISO"])
      expect(theme.logos_light).to eq({ "ISO" => "iso-logo.svg" })
      expect(theme.preface_wrap).to be(true)
      expect(theme.toc_filter_types).to eq(["toc"])
      expect(theme.text_color).to eq("#1a1a2e")
    end

    it "preserves defaults for missing keys" do
      yaml = "primary: \"#ff0000\""
      theme = described_class.from_yaml(yaml)
      expect(theme.primary).to eq("#ff0000")
      expect(theme.accent).to eq("#9C60C1")
      expect(theme.preface_wrap).to be(false)
      expect(theme.publishers).to eq([])
      expect(theme.toc_filter_types).to eq([])
    end
  end
end
