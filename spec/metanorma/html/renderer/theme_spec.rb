# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/theme"

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
end
