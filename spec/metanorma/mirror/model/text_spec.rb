# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Text do
  it "stores text and marks" do
    mark = Metanorma::Mirror::Model::Mark.new(type: "emphasis")
    text = described_class.new(text: "hello", marks: [mark])
    text.text.should eq("hello")
    text.marks.should eq([mark])
  end

  it "returns type as 'text'" do
    text = described_class.new(text: "hello")
    text.type.should eq("text")
  end

  it "coerces text to string" do
    text = described_class.new(text: 42)
    text.text.should eq("42")
  end

  it "defaults marks to empty array" do
    text = described_class.new(text: "hello")
    text.marks.should eq([])
  end

  it "serializes to hash with marks" do
    mark = Metanorma::Mirror::Model::Mark.new(type: "strong")
    text = described_class.new(text: "bold", marks: [mark])
    h = text.to_h
    h.should eq({
                  "type" => "text",
                  "text" => "bold",
                  "marks" => [{ "type" => "strong" }],
                })
  end

  it "omits marks when empty" do
    text = described_class.new(text: "plain")
    h = text.to_h
    h.should_not have_key("marks")
  end

  describe "#text_content" do
    it "returns its own text" do
      text = described_class.new(text: "hello")
      text.text_content.should eq("hello")
    end

    it "returns text regardless of marks" do
      mark = Metanorma::Mirror::Model::Mark.new(type: "strong")
      text = described_class.new(text: "bold", marks: [mark])
      text.text_content.should eq("bold")
    end
  end
end
