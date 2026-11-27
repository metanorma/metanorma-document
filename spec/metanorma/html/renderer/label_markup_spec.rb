# frozen_string_literal: true

require "nokogiri"
require "spec_helper"
require "liquid"
require "metanorma/html/generator"

# Admonition labels come from the presentation XML's localized fmt-name,
# figure key titles keep their inline markup, and acronym doctypes keep
# their capitals on the cover.
RSpec.describe "HTML renderer label and title fidelity" do
  let(:path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) { File.read(path) }

  def page_for(source)
    Nokogiri::HTML(
      Metanorma::Html::Generator.generate(
        Metanorma::Iso::Document::Root.from_xml(source),
      ),
    )
  end

  it "renders the localized admonition label with its delimiter" do
    fr = xml.sub('<span class="fmt-element-name">WARNING</span>',
                 '<span class="fmt-element-name">AVERTISSEMENT</span>')
    titles = page_for(fr).css(".admonition-title").map { |t| t.text.strip }
    expect(titles).to include("AVERTISSEMENT —")
    expect(titles).to include("CAUTION —")
    expect(titles).not_to include("Warning")
  end

  it "keeps inline markup in a figure key title" do
    marked = xml.sub("<name>Key</name>", "<name>Key <em>legend</em></name>")
    expect(marked).not_to eq(xml)
    title = page_for(marked).at_css(".key-title")
    expect(title.at_css("em").text).to eq("legend")
  end

  it "keeps acronym doctypes in capitals on the cover" do
    template = File.expand_path(
      "../../../../lib/metanorma/html/templates/_standard_cover.html.liquid", __dir__
    )
    html = Liquid::Template.parse(File.read(template))
      .render("doctype" => "PAS", "cover" => { "tc_docnumber" => [] })
    expect(html).to include('<p class="cover-doctype">PAS</p>')
  end
end
