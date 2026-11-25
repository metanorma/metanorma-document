# frozen_string_literal: true

require "spec_helper"

RSpec.describe "OIML HTML theme palette" do
  let(:theme) { Metanorma::Html::Theme.load(:oiml) }
  let(:iso) { Metanorma::Html::Theme.load(:iso) }
  let(:css) { theme.to_css }

  it "carries OIML's own blue, not the inherited ISO red" do
    expect(theme.primary).to eq("#004996")
    expect(theme.accent).to eq("#004996")
    expect(theme.warm).to eq("#D4A017")
    expect(theme.accent).not_to eq(iso.accent)
    expect(theme.primary).not_to eq(iso.primary)
  end

  it "leaves no ISO palette value in the emitted custom properties" do
    expect(css).to include("--mn-primary: #004996", "--mn-accent: #004996")
    expect(css).not_to match(/#b3000c|#e3000f|#8a0009|#5a0006|#ff4d4d|#fde8ea|#fef0f1|227,0,15/i)
  end

  it "keeps OIML's logo, publisher and cover/intro slots" do
    expect(theme.publisher_name).to eq("International Organization of Legal Metrology")
    expect(theme.cover_template).to eq("cover.html.liquid")
    expect(theme.resolve_template("cover.html.liquid")).to include("themes/oiml/templates")
  end

  it "lets OIML-CS inherit the OIML palette" do
    expect(Metanorma::Html::Theme.load(:"oiml-cs").primary).to eq("#004996")
  end
end
