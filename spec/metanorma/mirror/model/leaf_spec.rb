# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Leaf do
  it "has type and attrs but no content" do
    leaf = described_class.new(type: "image", attrs: { src: "img.png" })
    expect(leaf.type).to eq("image")
    expect(leaf.attrs).to eq("src" => "img.png")
    expect(leaf.leaf?).to be(true)
    expect(leaf.container?).to be(false)
  end

  it "serializes to hash without content" do
    leaf = described_class.new(type: "image", attrs: { src: "img.png" })
    h = leaf.to_h
    expect(h).to eq({ "type" => "image", "attrs" => { "src" => "img.png" } })
  end

  describe "#text_content" do
    it "returns empty string" do
      leaf = described_class.new(type: "image")
      expect(leaf.text_content).to eq("")
    end
  end
end
