# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Guide do
  it "stores content, meta, and title" do
    doc = Metanorma::Mirror::Model::Container.new(type: "doc")
    guide = described_class.new(content: doc, meta: { "title" => "Test" },
                                title: "Test Doc")
    expect(guide.content).to eq(doc)
    expect(guide.meta).to eq({ "title" => "Test" })
    expect(guide.title).to eq("Test Doc")
  end

  it "defaults meta to empty hash" do
    guide = described_class.new(content: nil)
    expect(guide.meta).to eq({})
  end

  it "defaults title to nil" do
    guide = described_class.new(content: nil)
    expect(guide.title).to be_nil
  end

  it "carries an optional source document" do
    document = Object.new
    guide = described_class.new(content: nil, document: document)
    expect(guide.document).to eq(document)
  end

  it "defaults document to nil and never serializes it" do
    expect(described_class.new(content: nil).document).to be_nil
    guide = described_class.new(content: nil, document: Object.new)
    expect(guide.to_h).not_to have_key("document")
  end

  it "serializes to hash" do
    doc = Metanorma::Mirror::Model::Container.new(type: "doc")
    guide = described_class.new(content: doc, meta: { "flavor" => "iso" },
                                title: "Doc")
    h = guide.to_h
    expect(h["content"]["type"]).to eq("doc")
    expect(h["meta"]["flavor"]).to eq("iso")
    expect(h["title"]).to eq("Doc")
  end
end
