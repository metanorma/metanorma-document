# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::Text do
  it "stores text and marks" do
    mark = Metanorma::Mirror::Model::Mark.new(type: "emphasis")
    text = described_class.new(text: "hello", marks: [mark])
    expect(text.text).to eq("hello")
    expect(text.marks).to eq([mark])
  end

  it "returns type as 'text'" do
    text = described_class.new(text: "hello")
    expect(text.type).to eq("text")
  end

  it "coerces text to string" do
    text = described_class.new(text: 42)
    expect(text.text).to eq("42")
  end

  it "defaults marks to empty array" do
    text = described_class.new(text: "hello")
    expect(text.marks).to eq([])
  end

  it "serializes to hash with marks" do
    mark = Metanorma::Mirror::Model::Mark.new(type: "strong")
    text = described_class.new(text: "bold", marks: [mark])
    h = text.to_h
    expect(h).to eq({
                      "type" => "text",
                      "text" => "bold",
                      "marks" => [{ "type" => "strong" }],
                    })
  end

  it "omits marks when empty" do
    text = described_class.new(text: "plain")
    h = text.to_h
    expect(h).not_to have_key("marks")
  end

  describe "#text_content" do
    it "returns its own text" do
      text = described_class.new(text: "hello")
      expect(text.text_content).to eq("hello")
    end

    it "returns text regardless of marks" do
      mark = Metanorma::Mirror::Model::Mark.new(type: "strong")
      text = described_class.new(text: "bold", marks: [mark])
      expect(text.text_content).to eq("bold")
    end
  end
end
