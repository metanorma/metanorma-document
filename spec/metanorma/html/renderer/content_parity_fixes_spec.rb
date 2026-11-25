# frozen_string_literal: true

# Content parity fixes for metanorma/metanorma-document#114: content present
# in the legacy isodoc HTML must not be lost by the new renderer.

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::Generator do
  # content parity with legacy isodoc (metanorma-document#114)
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:doc) { Metanorma::Iso::Document::Root.from_xml(File.read(xml_path)) }
  let(:page) { Nokogiri::HTML(described_class.generate(doc)) }

  it "renders a term example that carries a definition list" do
    expect { described_class.generate(doc) }.not_to raise_error
    expect(page.css(".example dl").size).to be >= 1
  end

  it "keeps the full example caption, number and delimiter included" do
    labels = page.css(".example-label").map { |n| n.text.strip }
    expect(labels).to include("EXAMPLE — Sample Code")
  end

  it "keeps the term note caption from the presentation XML" do
    labels = page.css(".term-note-label").map { |n| n.text.strip }
    expect(labels).to all(eq("Note 1 to entry:"))
    expect(page.css(".term-note-label").first.text).to end_with(": ")
  end
end
