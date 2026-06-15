# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Leaf do
  it "has type and attrs but no content" do
    leaf = described_class.new(type: "image", attrs: { src: "img.png" })
    leaf.type.should eq("image")
    leaf.attrs.should eq("src" => "img.png")
    leaf.leaf?.should be(true)
    leaf.container?.should be(false)
  end

  it "serializes to hash without content" do
    leaf = described_class.new(type: "image", attrs: { src: "img.png" })
    h = leaf.to_h
    h.should eq({ "type" => "image", "attrs" => { "src" => "img.png" } })
  end
end
