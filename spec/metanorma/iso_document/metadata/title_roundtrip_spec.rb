# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "Title round-trip" do
  let(:xml) { File.read("spec/fixtures/iso/is/document-en.xml") }
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
  let(:bibdata) { doc.bibdata }

  it "parses title items with type attribute" do
    bibdata.titles.items.each do |item|
    end

    bibdata.titles.per_language.each do |g|
    end
  end
end
