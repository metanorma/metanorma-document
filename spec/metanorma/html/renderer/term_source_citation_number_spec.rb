# frozen_string_literal: true

require "nokogiri"
require "spec_helper"
require "metanorma/html/generator"

# Presentation XML can put the bibliography number in a second <fmt-xref>
# whose only child is <sup>[7]</sup>. The model dropped that child, so the
# term source printed "[SOURCE: IP 309 ]" where isodoc prints
# "[SOURCE: IP 309[7] ]".
RSpec.describe "HTML renderer term source citation number" do
  let(:path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:xml) do
    File.read(path).sub(
      %r{(<fmt-termsource[^>]*>.*?)(</semx>\]</fmt-termsource>)}m,
      '\1<fmt-xref target="ISO20483"><sup>[7]</sup></fmt-xref>' \
      '\2',
    )
  end
  let(:page) do
    Nokogiri::HTML(
      Metanorma::Html::Generator.generate(
        Metanorma::Iso::Document::Root.from_xml(xml),
      ),
    )
  end

  it "keeps the number of the cited reference" do
    expect(xml).to include('<sup>[7]</sup></fmt-xref>')
    sources = page.css("p.term-source").map { |p| p.text }
    expect(sources.first).to include("[7]")
  end
end
