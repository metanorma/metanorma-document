# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Mark do
  it "stores type and attrs" do
    mark = described_class.new(type: "link",
                               attrs: { href: "https://example.com" })
    expect(mark.type).to eq("link")
    expect(mark.attrs).to eq("href" => "https://example.com")
  end

  it "normalizes attrs keys to strings" do
    mark = described_class.new(type: "xref", attrs: { target: "s1" })
    expect(mark.attrs).to have_key("target")
  end

  it "serializes to hash" do
    mark = described_class.new(type: "emphasis")
    expect(mark.to_hash).to eq({ "type" => "emphasis" })
  end

  it "omits attrs when empty" do
    mark = described_class.new(type: "emphasis")
    expect(mark.to_hash).not_to have_key("attrs")
  end

  describe ".from_hash" do
    it "creates mark from hash" do
      mark = described_class.from_hash({ "type" => "link",
                                         "attrs" => { "href" => "http://x.co" } })
      expect(mark.type).to eq("link")
      expect(mark.attrs["href"]).to eq("http://x.co")
    end

    it "rejects nil input" do
      # nil is not a wire value; the framework owns the contract
      expect { described_class.from_hash(nil) }
        .to raise_error(Lutaml::Model::InvalidFormatError)
    end

    it "defaults attrs to empty hash" do
      mark = described_class.from_hash({ "type" => "emphasis" })
      expect(mark.attrs).to eq({})
    end
  end

  describe "#[] and #[]=" do
    it "reads attrs via string or symbol keys" do
      mark = described_class.new(type: "xref", attrs: { "target" => "s1" })
      expect(mark[:target]).to eq("s1")
      expect(mark["target"]).to eq("s1")
    end

    it "writes attrs via string or symbol keys" do
      mark = described_class.new(type: "xref", attrs: { "target" => "s1" })
      mark[:target] = "s2"
      expect(mark["target"]).to eq("s2")
      mark[:new_key] = "v"
      expect(mark["new_key"]).to eq("v")
    end
  end

  describe "#set_attr" do
    it "sets the attr and returns self for chaining" do
      mark = described_class.new(type: "xref")
      returned = mark.set_attr(:target, "s1")
      expect(returned).to equal(mark)
      expect(mark["target"]).to eq("s1")
    end
  end

  describe "#fetch" do
    it "returns the value when key exists" do
      mark = described_class.new(type: "xref", attrs: { "target" => "s1" })
      expect(mark.fetch(:target)).to eq("s1")
    end

    it "returns the default when key is missing" do
      mark = described_class.new(type: "xref")
      expect(mark.fetch(:missing, "default")).to eq("default")
    end

    it "yields to block when key is missing" do
      mark = described_class.new(type: "xref")
      expect(mark.fetch(:missing, "block")).to eq("block")
    end
  end

  describe "round-trip" do
    it "to_hash then from_hash yields equivalent mark" do
      original = described_class.new(type: "link",
                                     attrs: {
                                       "href" => "http://x.co", "title" => "X"
                                     })
      restored = described_class.from_hash(original.to_hash)
      expect(restored.type).to eq(original.type)
      expect(restored.attrs).to eq(original.attrs)
    end
  end
end
