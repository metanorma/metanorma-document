# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Container do
  it "holds content array" do
    child = described_class.new(type: "paragraph")
    container = described_class.new(type: "clause", content: [child])
    expect(container.content).to eq([child])
  end

  it "defaults content to empty array" do
    container = described_class.new(type: "clause")
    expect(container.content).to eq([])
  end

  it "wraps non-array content in array" do
    child = described_class.new(type: "paragraph")
    container = described_class.new(type: "clause", content: child)
    expect(container.content).to eq([child])
  end

  it "is a container" do
    container = described_class.new(type: "clause")
    expect(container.container?).to be(true)
    expect(container.leaf?).to be(false)
  end

  it "serializes to hash with content" do
    child = described_class.new(type: "paragraph", attrs: { id: "p1" })
    container = described_class.new(type: "clause", attrs: { id: "s1" },
                                    content: [child])
    h = container.to_hash
    expect(h["type"]).to eq("clause")
    expect(h["attrs"]).to eq("id" => "s1")
    expect(h["content"]).to be_an(Array)
    expect(h["content"].size).to eq(1)
    expect(h["content"][0]["type"]).to eq("paragraph")
  end

  it "omits content when empty" do
    container = described_class.new(type: "clause")
    h = container.to_hash
    expect(h).not_to have_key("content")
  end

  it "serializes string children directly" do
    text = Metanorma::Mirror::Model::Text.new(text: "hello")
    container = described_class.new(type: "paragraph", content: [text])
    h = container.to_hash
    expect(h["content"][0]).to eq({ "type" => "text", "text" => "hello" })
  end

  it "extracts text content from children" do
    t1 = Metanorma::Mirror::Model::Text.new(text: "Hello ")
    t2 = Metanorma::Mirror::Model::Text.new(text: "world")
    container = described_class.new(type: "paragraph", content: [t1, t2])
    expect(container.text_content).to eq("Hello world")
  end
end
