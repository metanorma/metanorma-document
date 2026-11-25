# frozen_string_literal: true

require "spec_helper"

RSpec.describe "vsd HTML theme palette" do
  let(:theme) { Metanorma::Html::Theme.load(:vsd) }
  let(:css) { theme.to_css }

  it "adds its own palette beyond the single brand colour" do
    expect(theme.primary).to eq("#007864")
    expect(theme.note_bg).to eq("#FFF495")
    expect(theme.example_bg).to eq("#E1EEF1")
  end

  it "emits its palette in the custom properties" do
    expect(css).to include("--mn-primary: #007864")
  end

  it "keeps its publisher name" do
    expect(theme.publisher_name).to eq("Vita Green")
  end
end
