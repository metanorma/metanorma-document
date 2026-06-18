# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Mark do
  it "stores type and attrs" do
    mark = described_class.new(type: "link",
                               attrs: { href: "https://example.com" })
    mark.type.should eq("link")
    mark.attrs.should eq("href" => "https://example.com")
  end

  it "normalizes attrs keys to strings" do
    mark = described_class.new(type: "xref", attrs: { target: "s1" })
    mark.attrs.should have_key("target")
  end

  it "serializes to hash" do
    mark = described_class.new(type: "emphasis")
    mark.to_h.should eq({ "type" => "emphasis" })
  end

  it "omits attrs when empty" do
    mark = described_class.new(type: "emphasis")
    mark.to_h.should_not have_key("attrs")
  end

  describe ".from_h" do
    it "creates mark from hash" do
      mark = described_class.from_h({ "type" => "link",
                                      "attrs" => { "href" => "http://x.co" } })
      mark.type.should eq("link")
      mark.attrs["href"].should eq("http://x.co")
    end

    it "returns nil for nil input" do
      described_class.from_h(nil).should be_nil
    end

    it "defaults attrs to empty hash" do
      mark = described_class.from_h({ "type" => "emphasis" })
      mark.attrs.should eq({})
    end
  end

  describe "#[] and #[]=" do
    it "reads attrs via string or symbol keys" do
      mark = described_class.new(type: "xref", attrs: { "target" => "s1" })
      mark[:target].should eq("s1")
      mark["target"].should eq("s1")
    end

    it "writes attrs via string or symbol keys" do
      mark = described_class.new(type: "xref", attrs: { "target" => "s1" })
      mark[:target] = "s2"
      mark["target"].should eq("s2")
      mark[:new_key] = "v"
      mark["new_key"].should eq("v")
    end
  end

  describe "#set_attr" do
    it "sets the attr and returns self for chaining" do
      mark = described_class.new(type: "xref")
      returned = mark.set_attr(:target, "s1")
      returned.should equal(mark)
      mark["target"].should eq("s1")
    end
  end

  describe "#fetch" do
    it "returns the value when key exists" do
      mark = described_class.new(type: "xref", attrs: { "target" => "s1" })
      mark.fetch(:target).should eq("s1")
    end

    it "returns the default when key is missing" do
      mark = described_class.new(type: "xref")
      mark.fetch(:missing, "default").should eq("default")
    end

    it "yields to block when key is missing" do
      mark = described_class.new(type: "xref")
      mark.fetch(:missing, "block").should eq("block")
    end
  end

  describe "round-trip" do
    it "to_h then from_h yields equivalent mark" do
      original = described_class.new(type: "link",
                                     attrs: {
                                       "href" => "http://x.co", "title" => "X"
                                     })
      restored = described_class.from_h(original.to_h)
      restored.type.should eq(original.type)
      restored.attrs.should eq(original.attrs)
    end
  end
end
