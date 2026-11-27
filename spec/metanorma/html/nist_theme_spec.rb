# frozen_string_literal: true

require "spec_helper"

RSpec.describe "nist HTML theme palette" do
  let(:theme) { Metanorma::Html::Theme.load(:nist) }
  let(:css) { theme.to_css }

  it "adds its own palette beyond the single brand colour" do
    expect(theme.primary).to eq("#006494")
    expect(theme.note_bg).to eq("#FFCA3A")
    expect(theme.example_bg).to eq("#E1EEF1")
  end

  it "emits its palette in the custom properties" do
    expect(css).to include("--mn-primary: #006494")
  end

  it "keeps its publisher name" do
    expect(theme.publisher_name).to eq("National Institute of Standards and Technology")
  end
end
