# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/theme"
require "fileutils"
require "tmpdir"

RSpec.describe Metanorma::Html::Theme do
  subject(:theme) { described_class.new }

  describe "defaults" do
    it "has a primary color" do
      theme.primary.should eq("#28388A")
    end

    it "has accent color" do
      theme.accent.should eq("#9C60C1")
    end

    it "has font stacks" do
      theme.font_body.should include("serif")
      theme.font_sans.should include("sans-serif")
      theme.font_mono.should include("monospace")
    end

    it "has block element defaults" do
      theme.note_border.should_not be_nil
      theme.example_border.should_not be_nil
      theme.admonition_border.should_not be_nil
    end

    it "has empty publishers by default" do
      theme.publishers.should eq([])
    end

    it "has nil publisher_name by default" do
      theme.publisher_name.should be_nil
    end

    it "has empty logos by default" do
      theme.logos.should eq({})
    end
  end

  describe ".load" do
    context "with unknown flavor" do
      it "returns default theme" do
        t = described_class.load(:nonexistent)
        t.primary.should eq("#28388A")
      end
    end

    %i[iso iec ieee ietf itu iho ogc bipm cc icc oiml ribose
       pdfa].each do |flavor|
      context "#{flavor} flavor" do
        let(:theme) { described_class.load(flavor) }

        it "loads without error" do
          theme.should_not be_nil
        end

        it "has a primary color" do
          theme.primary.should_not be_nil
        end

        it "has an accent color" do
          theme.accent.should_not be_nil
        end

        it "has fonts" do
          theme.font_body.should_not be_nil
          theme.font_sans.should_not be_nil
          theme.font_mono.should_not be_nil
        end
      end
    end

    context "ISO theme" do
      let(:theme) { described_class.load(:iso) }

      it "has red primary color" do
        theme.primary.should eq("#b3000c")
      end

      it "has publisher metadata" do
        theme.publishers.should include("ISO")
      end

      it "has publisher_name" do
        theme.publisher_name.should eq("ISO")
      end

      it "has logo map" do
        theme.logos.should include("ISO")
      end
    end

    context "IEC theme" do
      let(:theme) { described_class.load(:iec) }

      it "has publisher metadata" do
        theme.publishers.should include("IEC")
      end
    end

    context "BIPM theme" do
      let(:theme) { described_class.load(:bipm) }

      it "has publisher metadata" do
        theme.publishers.should include("BIPM")
      end
    end
  end

  describe "#to_css_root" do
    let(:css) { theme.to_css_root }

    it "emits :root CSS block" do
      css.should include(":root {")
    end

    it "includes primary color variable" do
      css.should include("--mn-primary: #28388A")
    end

    it "includes accent color variable" do
      css.should include("--mn-accent: #9C60C1")
    end

    it "includes font variables" do
      css.should include("--font-body:")
      css.should include("--font-sans:")
      css.should include("--font-mono:")
    end

    it "includes block element variables" do
      css.should include("--note-bg:")
      css.should include("--example-border:")
      css.should include("--admonition-color:")
    end

    it "includes dark mode overrides" do
      css.should include('[data-theme="dark"]')
      css.should include("--color-bg: #0f1118")
    end

    it "omits header_background when nil" do
      theme.header_background = nil
      css.should_not include("--mn-header-bg")
    end

    it "includes header_background when set" do
      theme.header_background = "linear-gradient(red, blue)"
      css.should include("--mn-header-bg: linear-gradient(red, blue)")
    end
  end

  describe "#to_css_extras" do
    it "returns empty string when no extras set" do
      theme.to_css_extras.strip.should be_empty
    end

    it "includes cover_before_bg when set" do
      theme.cover_before_bg = "background: red"
      theme.to_css_extras.should include("title-section::before")
    end

    it "includes extra_css when set" do
      theme.extra_css = ".foo { color: red }"
      theme.to_css_extras.should include(".foo { color: red }")
    end
  end

  describe "overriding in subclass" do
    it "allows changing colors" do
      t = described_class.new
      t.primary = "#ff0000"
      t.primary.should eq("#ff0000")
    end
  end

  describe "section ordering defaults" do
    it "has default preface_order" do
      theme.preface_order.should eq(%w[foreword introduction abstract clause
                                       acknowledgements executivesummary])
    end

    it "has default clause_order" do
      theme.clause_order.should eq(%w[sections annex bibliography indexsect])
    end

    it "has preface_wrap false by default" do
      theme.preface_wrap.should be(false)
    end

    it "has empty toc_filter_types by default" do
      theme.toc_filter_types.should eq([])
    end
  end

  describe "OGC theme overrides" do
    let(:theme) { described_class.load(:ogc) }

    it "has clause-only preface_order" do
      theme.preface_order.should eq(%w[clause])
    end

    it "has preface_wrap enabled" do
      theme.preface_wrap.should be(true)
    end

    it "filters toc clause types" do
      theme.toc_filter_types.should eq(%w[toc])
    end

    it "has nil theme_dir when loaded from flat file" do
      theme.theme_dir.should be_nil
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
      theme.should_not be_nil
    end

    it "reads config from theme.yaml" do
      theme.primary.should eq("#ff0000")
    end

    it "sets theme_dir to the flavor directory" do
      theme.theme_dir.should eq(File.join(tmpdir, "testflavor"))
    end

    it "exposes theme_templates_dir" do
      theme.theme_templates_dir.should eq(File.join(tmpdir, "testflavor",
                                                    "templates"))
    end

    it "exposes theme_assets_dir" do
      theme.theme_assets_dir.should eq(File.join(tmpdir, "testflavor",
                                                 "assets"))
    end

    it "exposes theme_css_path" do
      theme.theme_css_path.should eq(File.join(tmpdir, "testflavor",
                                               "custom.css"))
    end

    it "resolves flavor-specific template" do
      path = theme.resolve_template("_custom.html.liquid")
      path.should eq(File.join(tmpdir, "testflavor", "templates",
                               "_custom.html.liquid"))
    end

    it "falls back to shared templates for unknown template" do
      path = theme.resolve_template("_nonexistent.html.liquid")
      path.should include("templates")
    end

    it "resolves flavor-specific asset" do
      path = theme.resolve_asset("test-logo.svg")
      path.should eq(File.join(tmpdir, "testflavor", "assets", "test-logo.svg"))
    end

    it "returns nil for missing asset" do
      theme.resolve_asset("nonexistent.svg").should be_nil
    end

    it "loads publisher metadata from directory theme" do
      theme.publishers.should eq(["TEST"])
      theme.publisher_name.should eq("TestPub")
    end

    it "loads section ordering from directory theme" do
      theme.preface_order.should eq(%w[introduction clause])
      theme.preface_wrap.should be(true)
    end
  end

  describe "flat file fallback" do
    it "still loads flat YAML themes" do
      theme = described_class.load(:iso)
      theme.should_not be_nil
      theme.theme_dir.should be_nil
    end

    it "returns default theme for unknown flavor" do
      theme = described_class.load(:nonexistent)
      theme.primary.should eq("#28388A")
      theme.theme_dir.should be_nil
    end
  end

  describe "template resolution without theme_dir" do
    let(:theme) { described_class.new }

    it "returns shared template path" do
      path = theme.resolve_template("_note.html.liquid")
      path.should include("templates")
    end

    it "returns nil for asset resolution" do
      theme.resolve_asset("logo.svg").should be_nil
    end

    it "returns nil for css path" do
      theme.theme_css_path.should be_nil
    end
  end

  describe "lutaml-model schema" do
    it "is a Lutaml::Model::Serializable" do
      described_class.ancestors.should include(Lutaml::Model::Serializable)
    end

    it "has 68 typed attributes" do
      described_class.attributes.size.should eq(68)
    end

    it "has boolean type for preface_wrap" do
      attr = described_class.attributes[:preface_wrap]
      attr.should_not be_nil
      attr.type.should eq(Lutaml::Model::Type::Boolean)
    end

    it "has collection flag on array attributes" do
      %i[publishers preface_order clause_order
         toc_filter_types].each do |name|
        described_class.attributes[name].collection?.should be(true)
      end
    end

    it "has hash type for logos" do
      attr = described_class.attributes[:logos]
      attr.type.should eq(Lutaml::Model::Type::Hash)
    end

    it "has string type for color attributes" do
      %i[primary accent note_bg dark_border].each do |name|
        described_class.attributes[name].type.should eq(Lutaml::Model::Type::String)
      end
    end

    it "loads from YAML via lutaml-model" do
      yaml = <<~YAML
        primary: "#b3000c"
        accent: "#ff6600"
        publishers:
          - ISO
        logos:
          ISO: iso-logo.svg
        preface_wrap: true
        toc_filter_types:
          - toc
      YAML
      theme = described_class.from_yaml(yaml)
      theme.primary.should eq("#b3000c")
      theme.accent.should eq("#ff6600")
      theme.publishers.should eq(["ISO"])
      theme.logos.should eq({ "ISO" => "iso-logo.svg" })
      theme.preface_wrap.should be(true)
      theme.toc_filter_types.should eq(["toc"])
      theme.text_color.should eq("#1a1a2e")
    end

    it "preserves defaults for missing keys" do
      yaml = "primary: \"#ff0000\""
      theme = described_class.from_yaml(yaml)
      theme.primary.should eq("#ff0000")
      theme.accent.should eq("#9C60C1")
      theme.preface_wrap.should be(false)
      theme.publishers.should eq([])
      theme.toc_filter_types.should eq([])
    end
  end
end
