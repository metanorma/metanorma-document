# frozen_string_literal: true

require "spec_helper"

RSpec.describe "JIS and PLATEAU HTML theme palettes" do
  let(:jis) { Metanorma::Html::Theme.load(:jis) }
  let(:plateau) { Metanorma::Html::Theme.load(:plateau) }

  it "gives JIS the stylesheet blue, not placeholder black" do
    expect(jis.primary).to eq("#485094")
    expect(jis.cover_background).to eq("#485094")
    expect(jis.note_bg).to eq("#FFF495")
    expect(jis.example_bg).to eq("#E1EEF1")
    expect(jis.to_css).to include("--mn-primary: #485094")
    expect(jis.to_css).not_to match(/--mn-(primary|accent): #000000/)
  end

  it "keeps JIS's publisher and serif CJK fonts" do
    expect(jis.publisher_name).to eq("日本産業規格")
    expect(jis.font_body).to include("Noto Serif CJK JP")
  end

  it "has PLATEAU inherit the JIS palette and keep its own publisher" do
    expect(plateau.primary).to eq(jis.primary)
    expect(plateau.note_bg).to eq(jis.note_bg)
    expect(plateau.publisher_name).to eq("PLATEAU")
    expect(plateau.to_css).not_to match(/--mn-(primary|accent): #000000/)
  end
end
