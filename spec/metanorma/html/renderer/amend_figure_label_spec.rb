# frozen_string_literal: true

require "nokogiri"
require "spec_helper"
require "metanorma/html/generator"

# Figures added by an amendment carry no numbered caption in the raw
# <newcontent>; the HTML renderer used to print the bare title and lose
# the "Figure A.1 — " label that the legacy isodoc output shows.
RSpec.describe "HTML renderer amendment figure caption" do
  let(:path) do
    File.expand_path("../../../fixtures/iso/amd/document-en.final.presentation.xml",
                     __dir__)
  end
  let(:page) do
    Nokogiri::HTML(
      Metanorma::Html::Generator.generate(
        Metanorma::Iso::Document::Root.from_xml(File.read(path)),
      ),
    )
  end

  it "prefixes the caption with the figure label from the amend autonumber" do
    source = Nokogiri::XML(File.read(path))
    source.remove_namespaces!
    label = source.at_xpath("//amend/autonumber[@type='figure']").text
    captions = page.css(".AmendNewcontent figcaption").map { |c| c.text.strip }
    expect(captions).to include(a_string_starting_with("Figure #{label} — "))
  end
end
