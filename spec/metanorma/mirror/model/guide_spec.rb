# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Guide do
  it "stores content, meta, and title" do
    doc = Metanorma::Mirror::Model::Container.new(type: "doc")
    guide = described_class.new(content: doc, meta: { "title" => "Test" },
                                title: "Test Doc")
    guide.content.should eq(doc)
    guide.meta.should eq({ "title" => "Test" })
    guide.title.should eq("Test Doc")
  end

  it "defaults meta to empty hash" do
    guide = described_class.new(content: nil)
    guide.meta.should eq({})
  end

  it "defaults title to nil" do
    guide = described_class.new(content: nil)
    guide.title.should be_nil
  end

  it "serializes to hash" do
    doc = Metanorma::Mirror::Model::Container.new(type: "doc")
    guide = described_class.new(content: doc, meta: { "flavor" => "iso" },
                                title: "Doc")
    h = guide.to_h
    h["content"]["type"].should eq("doc")
    h["meta"]["flavor"].should eq("iso")
    h["title"].should eq("Doc")
  end
end
