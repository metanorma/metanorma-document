# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Node do
  it "stores type and attrs" do
    node = described_class.new(type: "clause", attrs: { id: "s1" })
    node.type.should eq("clause")
    node.attrs.should eq("id" => "s1")
  end

  it "normalizes attrs keys to strings" do
    node = described_class.new(type: "clause", attrs: { id: "s1" })
    node.attrs.should have_key("id")
    node.attrs.should_not have_key(:id)
  end

  it "defaults attrs to empty hash" do
    node = described_class.new(type: "clause")
    node.attrs.should eq({})
  end

  it "handles nil attrs" do
    node = described_class.new(type: "clause", attrs: nil)
    node.attrs.should eq({})
  end

  it "serializes to hash" do
    node = described_class.new(type: "clause", attrs: { id: "s1" })
    h = node.to_h
    h.should eq({ "type" => "clause", "attrs" => { "id" => "s1" } })
  end

  it "omits attrs when empty" do
    node = described_class.new(type: "clause")
    node.to_h.should eq({ "type" => "clause" })
  end

  it "is not a leaf or container by default" do
    node = described_class.new(type: "clause")
    node.leaf?.should be(false)
    node.container?.should be(false)
  end
end
