# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Container do
  it "holds content array" do
    child = described_class.new(type: "paragraph")
    container = described_class.new(type: "clause", content: [child])
    container.content.should eq([child])
  end

  it "defaults content to empty array" do
    container = described_class.new(type: "clause")
    container.content.should eq([])
  end

  it "wraps non-array content in array" do
    child = described_class.new(type: "paragraph")
    container = described_class.new(type: "clause", content: child)
    container.content.should eq([child])
  end

  it "is a container" do
    container = described_class.new(type: "clause")
    container.container?.should be(true)
    container.leaf?.should be(false)
  end

  it "serializes to hash with content" do
    child = described_class.new(type: "paragraph", attrs: { id: "p1" })
    container = described_class.new(type: "clause", attrs: { id: "s1" },
                                    content: [child])
    h = container.to_h
    h["type"].should eq("clause")
    h["attrs"].should eq("id" => "s1")
    h["content"].should be_an(Array)
    h["content"].size.should eq(1)
    h["content"][0]["type"].should eq("paragraph")
  end

  it "omits content when empty" do
    container = described_class.new(type: "clause")
    h = container.to_h
    h.should_not have_key("content")
  end

  it "serializes string children directly" do
    text = Metanorma::Mirror::Model::Text.new(text: "hello")
    container = described_class.new(type: "paragraph", content: [text])
    h = container.to_h
    h["content"][0].should eq({ "type" => "text", "text" => "hello" })
  end

  it "extracts text content from children" do
    t1 = Metanorma::Mirror::Model::Text.new(text: "Hello ")
    t2 = Metanorma::Mirror::Model::Text.new(text: "world")
    container = described_class.new(type: "paragraph", content: [t1, t2])
    container.text_content.should eq("Hello world")
  end
end
