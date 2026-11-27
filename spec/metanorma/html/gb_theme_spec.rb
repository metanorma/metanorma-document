# frozen_string_literal: true

require "spec_helper"

RSpec.describe "GB HTML theme palette" do
  let(:theme) { Metanorma::Html::Theme.load(:gb) }
  let(:css) { theme.to_css }

  it "carries the GB stylesheet's heading blue and cover orange, not black" do
    expect(theme.primary).to eq("#485094")
    expect(theme.accent).to eq("#F36F36")
    expect(theme.cover_background).to eq("#485094")
    expect(theme.note_bg).to eq("#FFF495")
    expect(theme.example_bg).to eq("#E1EEF1")
  end

  it "leaves no placeholder black in the emitted custom properties" do
    expect(css).to include("--mn-primary: #485094", "--mn-accent: #F36F36")
    expect(css).not_to match(/--mn-(primary|accent): #000000/)
  end

  it "keeps GB's publisher and fonts" do
    expect(theme.publisher_name).to eq("中华人民共和国国家标准")
    expect(theme.font_body).to include("Source Han Sans SC")
  end
end
