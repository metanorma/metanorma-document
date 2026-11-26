# frozen_string_literal: true

require "nokogiri"
require "spec_helper"
require "metanorma/html/generator"

# A <key> placed directly in a table cell (ISO Directives Part 2 style
# table legend) used to be dropped by the HTML renderer, losing the
# legend text that the legacy isodoc output keeps.
RSpec.describe "HTML renderer table cell key" do
  let(:path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:legend) do
    '<key><name>Key</name><dl><dt>ZQ</dt><dd><p>Legend entry text</p></dd></dl></key>'
  end
  let(:page) do
    xml = File.read(path)
    xml = xml.sub(%r{(<td\b[^>]*>)}, "\\1#{legend}")
    Nokogiri::HTML(
      Metanorma::Html::Generator.generate(
        Metanorma::Iso::Document::Root.from_xml(xml),
      ),
    )
  end

  it "renders the key title and definition list inside the cell" do
    text = page.css("td").map(&:text).join(" ").gsub(/\s+/, " ")
    expect(text).to include("Legend entry text")
    expect(page.css("td .key-title").map(&:text)).to include("Key")
  end
end
