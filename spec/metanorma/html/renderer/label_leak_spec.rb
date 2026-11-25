# frozen_string_literal: true

require "nokogiri"
require "spec_helper"
require "metanorma/html/generator"

# Regression specs for the HTML renderer on the ISO international-standard
# presentation fixture: heading label leak, repeated table footnotes and
# Array-valued definition lists.
RSpec.describe "HTML renderer label and footnote regressions" do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:doc) { Metanorma::Iso::Document::Root.from_xml(File.read(xml_path)) }
  let(:page) { Nokogiri::HTML(Metanorma::Html::Generator.generate(doc)) }

  describe "cross-reference labels" do
    it "does not print the fmt-xref-label after a clause heading" do
      scope = page.at_xpath('//div[h1[contains(., "Scope")]]')
      expect(scope).not_to be_nil
      expect(scope.xpath("./span[contains(@class, 'element-label')]")).to be_empty
      expect(scope.xpath("./text()").text.strip).to be_empty
    end

    it "does not print a label as body text under any heading" do
      leaked = page.xpath("//h1/following-sibling::*[1]" \
                          "[self::span[contains(@class, 'element-label')]]")
      expect(leaked).to be_empty
    end

    it "keeps the label inside cross-reference links" do
      expect(page.css("a.xref .element-label").map(&:text)).to include("Annex")
    end
  end

  describe "table footnotes" do
    it "lists each distinct footnote once" do
      labels = page.css("[id^='table-1-footnote-'] .TableFootnoteRef")
        .map(&:text)
      expect(labels).to eq(labels.uniq)
      expect(labels).to include("a", "b", "c")
    end

    it "points repeated markers at the shared footnote with unique ids" do
      markers = page.css("a.fn-link[href='#table-1-footnote-3']")
      expect(markers.size).to be > 1
      ids = page.css("a.fn-link[id^='table-1-fnref-']").map { |a| a["id"] }
      expect(ids).to eq(ids.uniq)
    end
  end

  describe "definition lists" do
    let(:renderer) { Metanorma::Html::StandardRenderer.new }
    let(:dl) do
      Metanorma::Document::Components::Lists::DefinitionList.from_xml(
        "<dl><dt>k</dt><dd><p>v</p></dd></dl>",
      )
    end

    it "renders an Array of lists (collection attribute) without error" do
      html = nil
      expect { html = renderer.render_definition_list([dl, dl]) }
        .not_to raise_error
      expect(html.scan("<dt>").size).to eq(2)
    end

    it "returns nil for an empty Array" do
      expect(renderer.render_definition_list([])).to be_nil
    end
  end
end
