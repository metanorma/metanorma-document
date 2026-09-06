# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Node do
  it "stores type and attrs" do
    node = described_class.new(type: "clause", attrs: { id: "s1" })
    expect(node.type).to eq("clause")
    expect(node.attrs).to eq("id" => "s1")
  end

  it "normalizes attrs keys to strings" do
    node = described_class.new(type: "clause", attrs: { id: "s1" })
    expect(node.attrs).to have_key("id")
    expect(node.attrs).not_to have_key(:id)
  end

  it "defaults attrs to empty hash" do
    node = described_class.new(type: "clause")
    expect(node.attrs).to eq({})
  end

  it "handles nil attrs" do
    node = described_class.new(type: "clause", attrs: nil)
    expect(node.attrs).to eq({})
  end

  it "serializes to hash" do
    node = described_class.new(type: "clause", attrs: { id: "s1" })
    h = node.to_hash
    expect(h).to eq({ "type" => "clause", "attrs" => { "id" => "s1" } })
  end

  it "omits attrs when empty" do
    node = described_class.new(type: "clause")
    expect(node.to_hash).to eq({ "type" => "clause" })
  end

  it "is not a leaf or container by default" do
    node = described_class.new(type: "clause")
    expect(node.leaf?).to be(false)
    expect(node.container?).to be(false)
  end
end
