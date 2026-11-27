# frozen_string_literal: true

require "spec_helper"

RSpec.describe "m3aawg HTML theme palette" do
  let(:theme) { Metanorma::Html::Theme.load(:m3aawg) }
  let(:css) { theme.to_css }

  it "adds its own palette beyond the single brand colour" do
    expect(theme.primary).to eq("#69C5DC")
    expect(theme.note_bg).to eq("#F5F6F6")
    expect(theme.example_bg).to eq("#E1EEF1")
  end

  it "emits its palette in the custom properties" do
    expect(css).to include("--mn-primary: #69C5DC")
  end

  it "keeps its publisher name" do
    expect(theme.publisher_name).to eq("M3AAWG")
  end
end
