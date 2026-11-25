# frozen_string_literal: true

require "spec_helper"

RSpec.describe "un HTML theme palette" do
  let(:theme) { Metanorma::Html::Theme.load(:un) }
  let(:css) { theme.to_css }

  it "adds its own palette beyond the single brand colour" do
    expect(theme.primary).to eq("#00ADEF")
    expect(theme.note_bg).to eq("#FFF495")
    expect(theme.example_bg).to eq("#E1EEF1")
  end

  it "emits its palette in the custom properties" do
    expect(css).to include("--mn-primary: #00ADEF")
  end

  it "keeps its publisher name" do
    expect(theme.publisher_name).to eq("United Nations Economic Commission for Europe")
  end
end
