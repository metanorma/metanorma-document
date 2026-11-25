# frozen_string_literal: true

require "spec_helper"

RSpec.describe "WMO HTML theme palette" do
  let(:theme) { Metanorma::Html::Theme.load(:wmo) }
  let(:iho) { Metanorma::Html::Theme.load(:iho) }
  let(:css) { theme.to_css }

  it "carries WMO's own heading blue and cover green, not the inherited IHO teal" do
    expect(theme.primary).to eq("#2F5496")
    expect(theme.accent).to eq("#229A3B")
    expect(theme.cover_background).to include("#229A3B")
    expect(theme.accent).not_to eq(iho.accent)
    expect(theme.primary).not_to eq(iho.primary)
  end

  it "leaves no IHO palette value in the emitted custom properties" do
    expect(css).to include("--mn-primary: #2F5496", "--mn-accent: #229A3B")
    expect(css).not_to match(/#00AAA9|#05164D|#008887|0,170,169/i)
  end

  it "keeps WMO's logo, publisher and cover/intro slots inherited from its own config" do
    expect(theme.publisher_name).to eq("World Meteorological Organization")
    expect(theme.cover_template).to eq("cover.html.liquid")
    expect(theme.resolve_template("cover.html.liquid")).to include("themes/wmo/templates")
  end
end
