# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Mark do
  describe "auto-registration" do
    expected_types = %w[
      emphasis strong subscript superscript code underline strike smallcap
      link xref eref footnote stem concept bcp14 span
    ]

    expected_types.each do |type|
      it "registers '#{type}' in MARKS" do
        described_class::MARKS[type].should be_a(Class)
      end
    end
  end

  describe "#initialize" do
    it "sets type from PM_TYPE constant" do
      mark = described_class::Emphasis.new
      mark.type.should eq("emphasis")
    end

    it "accepts attrs" do
      mark = described_class::Link.new(attrs: { href: "https://example.com" })
      mark.attrs[:href].should eq("https://example.com")
    end
  end

  describe "#to_h" do
    it "serializes type" do
      mark = described_class::Emphasis.new
      mark.to_h.should eq({ "type" => "emphasis" })
    end

    it "includes attrs when present" do
      mark = described_class::Link.new(attrs: { href: "https://example.com" })
      mark.to_h.should eq({ "type" => "link",
                            "attrs" => { "href" => "https://example.com" } })
    end

    it "omits empty attrs" do
      mark = described_class::Emphasis.new
      mark.to_h.should_not have_key("attrs")
    end
  end

  describe ".from_h" do
    it "reconstructs a mark by type" do
      mark = described_class.from_h({ "type" => "emphasis" })
      mark.should be_a(described_class::Emphasis)
    end

    it "reconstructs attrs" do
      mark = described_class.from_h({ "type" => "link",
                                      "attrs" => { "href" => "https://example.com" } })
      mark.should be_a(described_class::Link)
      mark.attrs[:href].should eq("https://example.com")
    end

    it "returns nil for nil input" do
      described_class.from_h(nil).should be_nil
    end
  end
end
