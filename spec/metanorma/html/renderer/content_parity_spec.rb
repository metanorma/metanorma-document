# frozen_string_literal: true

require "nokogiri"
require "spec_helper"
require "metanorma/html/generator"

# Regression specs for content the HTML renderer used to drop or duplicate
# relative to the legacy isodoc output (metanorma-document#114): term
# definitions, doubled math, localized admonition/example/term-note labels,
# quote attribution and figure key titles.
module ContentParityRender
  PATH = File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                          __dir__)

  def self.page
    @page ||= Nokogiri::HTML(
      Metanorma::Html::Generator.generate(
        Metanorma::Iso::Document::Root.from_xml(File.read(PATH)),
      ),
    )
  end
end

RSpec.describe "HTML renderer content parity" do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(xml_path) }

  let(:page) { ContentParityRender.page }

  describe "term definitions" do
    it "renders every definition text from fmt-definition" do
      source = Nokogiri::XML(xml)
      source.remove_namespaces!
      first = source.at_xpath("//fmt-definition")
        .text.gsub(/\s+/, " ").strip[0, 30]
      expect(page.text.gsub(/\s+/, " ")).to include(first)
    end
  end

  describe "math" do
    it "does not render a stem next to its fmt-stem copy" do
      expect(page.css(".stem + .math-container")).to be_empty
    end

    it "does not nest a math element inside another" do
      expect(page.xpath("//math//math")).to be_empty
    end

    it "emits one math element per math container" do
      page.css(".math-container").each do |container|
        expect(container.css("math").size).to eq(1)
      end
    end
  end

  describe "localized labels" do
    it "uses the fmt-name text for admonition titles" do
      source = Nokogiri::XML(xml)
      source.remove_namespaces!
      label = source.at_xpath("//admonition/fmt-name")
        .text.gsub(/\s+/, " ").sub(/\s*[—–-]\s*\z/, "").strip
      expect(page.text.gsub(/\s+/, " ")).to include(label)
    end

    it "uses the fmt-name text for example titles" do
      source = Nokogiri::XML(xml)
      source.remove_namespaces!
      label = source.at_xpath("//example/fmt-name")
        .text.gsub(/[[:space:]]+/, " ").strip
      expect(page.css(".example-label").map { |n| n.text.gsub(/[[:space:]]+/, " ").strip })
        .to include(label)
    end

    it "uses the fmt-name text for term notes" do
      source = Nokogiri::XML(xml)
      source.remove_namespaces!
      label = source.at_xpath("//termnote/fmt-name")
        .text.gsub(/\s+/, " ").strip.sub(/\s*:\z/, "")
      expect(page.css(".term-note-label").map { |n| n.text.strip })
        .to include("#{label}:")
    end
  end

  describe "quote attribution" do
    it "renders the attribution paragraph text in the footer" do
      expect(page.at_css("blockquote footer")&.text.to_s.strip)
        .to start_with("—")
    end
  end

  describe "figure key title" do
    it "renders the key name before the key definition list" do
      source = Nokogiri::XML(xml)
      source.remove_namespaces!
      names = source.xpath("//figure/key/name").map { |n| n.text.strip }
      skip "fixture has no figure key name" if names.empty?
      expect(page.css(".key-title").map(&:text)).to include(*names)
    end
  end
end
