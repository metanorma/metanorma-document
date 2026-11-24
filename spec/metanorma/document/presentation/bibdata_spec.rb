# frozen_string_literal: true

require "spec_helper"
require "isodoc"
require "metanorma-iso"
require "nokogiri"

RSpec.describe Metanorma::Document::Presentation::Behaviours::Bibdata do
  let(:presentation) { Metanorma::Document::Presentation }
  let(:ns) { "http://riboseinc.com/isoxml" }
  let(:layers) do
    presentation::ProfileLoader.from_file(File.expand_path("../../../fixtures/presentation/behaviours.lml", __dir__))
  end

  def source(lang)
    <<~XML
      <iso-standard xmlns="#{ns}"><bibdata type="standard"><title language="#{lang}" type="main">T</title><edition>2</edition>
      <language>#{lang}</language><language>de</language><script>Latn</script><status><stage>60</stage><substage>60</substage></status>
      <contributor><role type="publisher"/><organization><name>ISO</name><address><street>1 Rue</street><street>Apt 2</street><city>Geneva</city><country>CH</country><postcode>1211</postcode></address></organization></contributor>
      <ext><doctype>international-standard</doctype></ext></bibdata>
      <sections><clause id="A" obligation="normative"><title>T</title><p id="p"><date value="2024-03-05" format="%-d %B %Y"/></p></clause></sections></iso-standard>
    XML
  end

  def isodoc_doc(klass, lang)
    Nokogiri::XML(klass.new({ lang: lang }).convert("t", source(lang), true))
  end

  # The bibdata of the isodoc output with the generated parts taken out,
  # so the engine has to make them: the model, then the engine's output.
  def engine_doc(doc, flavor:, taste: nil)
    plain = doc.dup
    plain.xpath("//xmlns:bibdata//*[@current]").each { |n| n.remove_attribute("current") }
    plain.xpath("//xmlns:fmt-date").each(&:remove)
    plain.xpath("//xmlns:bibdata//*[@language='en' or @language='fr'][not(self::xmlns:title)]").each(&:remove)
    plain.xpath("//xmlns:bibdata//*[@language='']").each { |n| n.remove_attribute("language") }
    plain.xpath("//xmlns:address").each do |a|
      a.children = "<street>1 Rue</street><street>Apt 2</street><city>Geneva</city><country>CH</country><postcode>1211</postcode>"
    end
    root = Metanorma::Iso::Document::Root.from_xml(plain.to_xml)
    base = presentation::LayeredProfile.resolve(layers, flavor: flavor, taste: taste)
    out = presentation::Engine.new(profile: presentation::Behaviours.profile(base)).call(root)
    Nokogiri::XML(out.to_xml(prefix: false))
  end

  def texts(doc, xpath)
    doc.xpath(xpath).map { |n| n.text.strip.gsub(/\s+/, " ") }
  end

  def marked(doc)
    doc.xpath("//*[local-name()='bibdata']/*[@current='true']").map { |n| [n.name, n.text] }
  end

  def address(doc)
    doc.at("//*[local-name()='formattedAddress']")&.children&.map { |n| n.name == "br" ? "|" : n.text }&.join
  end

  [["base", IsoDoc::PresentationXMLConvert, nil], ["iso", IsoDoc::Iso::PresentationXMLConvert, "iso"]].each do |name, klass, flavor|
    context "with the #{name} profile" do
      let(:want) { isodoc_doc(klass, "en") }
      let(:got) { engine_doc(want, flavor: flavor) }

      it "marks the current language and script as isodoc does" do
        expect(marked(want)).to eq([%w[language en], %w[script Latn]])
        expect(marked(got)).to eq(marked(want))
      end

      it "makes formattedAddress from the address parts as isodoc does" do
        expect(address(want)).to eq("1 Rue|Apt 2|Geneva|CH 1211")
        expect(address(got)).to eq(address(want))
      end
    end
  end

  it "adds translated doctype, stage and edition in the document language, as the ISO flavor does" do
    want = isodoc_doc(IsoDoc::Iso::PresentationXMLConvert, "fr")
    got = engine_doc(want, flavor: "iso")
    %w[ext/*[local-name()='doctype'] status/*[local-name()='stage'] *[local-name()='edition']].each do |path|
      xp = "//*[local-name()='bibdata']/#{path}"
      expect(texts(got, xp)).to eq(texts(want, xp))
    end
    expect(texts(want, "//*[local-name()='bibdata']//*[local-name()='doctype']")).to include("Norme internationale")
    expect(texts(got, "//*[local-name()='bibdata']//*[local-name()='edition']")).to include("deuxième édition")
  end

  it "renders month names in the document language, as isodoc does" do
    want = isodoc_doc(IsoDoc::PresentationXMLConvert, "fr")
    got = engine_doc(want, flavor: nil, taste: "document_language_dates")
    expect(texts(want, "//*[local-name()='fmt-date']")).to eq(["5 mars 2024"])
    expect(texts(got, "//*[local-name()='fmt-date']")).to eq(["5 mars 2024"])
  end
end
