# frozen_string_literal: true

require "spec_helper"
require "isodoc"
require "metanorma-iso"
require "nokogiri"

RSpec.describe Metanorma::Document::Presentation::Behaviours::Terms do
  let(:presentation) { Metanorma::Document::Presentation }
  let(:ns) { "http://riboseinc.com/isoxml" }
  let(:layers) do
    presentation::ProfileLoader.from_file(File.expand_path("../../../fixtures/presentation/behaviours.lml", __dir__))
  end

  def source(autonum: nil)
    <<~XML
      <iso-standard xmlns="#{ns}"><bibdata type="standard"><title language="en" type="main">T</title><language>en</language><script>Latn</script></bibdata>
      <sections><terms id="T" obligation="normative"#{%( autonum="#{autonum}") if autonum}><title>Terms</title>
      <term id="t1"><preferred><expression><name>alpha</name></expression></preferred><admitted><expression><name>beta</name></expression></admitted><deprecates><expression><name>gamma</name></expression></deprecates>
      <domain>math</domain><definition><verbal-definition><p id="d">A def</p></verbal-definition></definition>
      <termnote id="n1"><p id="n1p">note</p></termnote><termnote id="n2"><p id="n2p">second</p></termnote><termexample id="e1"><p id="e1p">ex</p></termexample>
      <source status="modified"><origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><localityStack><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></localityStack></origin><modification><p id="m">mod</p></modification></source></term>
      <term id="t2"><preferred><expression><name>delta</name></expression></preferred><definition><verbal-definition><p id="d2">D2</p></verbal-definition></definition></term></terms></sections>
      <bibliography><references id="R" normative="true" obligation="informative"><title>Normative references</title><bibitem id="ISO7301" type="standard"><formattedref>ISO 7301</formattedref><docidentifier>ISO 7301:2011</docidentifier></bibitem></references></bibliography></iso-standard>
    XML
  end

  checks = {
    "term numbers" => "fmt-name",
    "term cross-reference labels" => "fmt-xref-label",
    "preferred designations" => "fmt-preferred",
    "admitted designations" => "fmt-admitted",
    "deprecated designations" => "fmt-deprecates",
    "definitions led by the domain" => "fmt-definition",
    "sources with modification" => "fmt-termsource",
  }.freeze

  def isodoc_doc(klass)
    Nokogiri::XML(klass.new({}).convert("t", source, true))
  end

  def engine_doc(flavor:, autonum: "2")
    root = Metanorma::Iso::Document::Root.from_xml(source(autonum: autonum))
    base = presentation::LayeredProfile.resolve(layers, flavor: flavor)
    out = presentation::Engine.new(profile: presentation::Behaviours.profile(base)).call(root)
    Nokogiri::XML(out.to_xml(prefix: false, pretty: false))
  end

  def texts(doc, xpath)
    doc.xpath(xpath).map { |n| n.dup.tap { |c| c.xpath(".//*[local-name()='origin']").each(&:remove) }.text.tr(" ", " ").gsub(/\s+/, " ").strip }
  end

  # The serializer indents elements-only models, which adds blanks between
  # the pieces of a label; labels are compared without blanks.
  def squashed(doc, xpath)
    texts(doc, xpath).map { |x| x.gsub(/\s+/, "") }
  end

  def t(name)
    "//*[local-name()='term']/*[local-name()='#{name}']"
  end

  [["base", IsoDoc::PresentationXMLConvert, nil], ["iso", IsoDoc::Iso::PresentationXMLConvert, "iso"]].each do |name, klass, flavor|
    context "with the #{name} profile" do
      let(:want) { isodoc_doc(klass) }
      let(:got) { engine_doc(flavor: flavor) }

      checks.each do |what, element|
        it "gives #{what} as isodoc does" do
          expect(texts(want, t(element))).not_to be_empty
          expect(squashed(got, t(element))).to eq(squashed(want, t(element)))
        end
      end

      it "labels term notes and examples as isodoc does" do
        described_class::KINDS.each do |kind|
          xp = "#{t(kind)}/*[local-name()='fmt-name']"
          expect(texts(want, xp)).not_to be_empty
          expect(squashed(got, xp)).to eq(squashed(want, xp))
        end
      end
    end
  end

  it "leaves terms unnumbered when their section has no number" do
    expect(texts(engine_doc(flavor: nil, autonum: nil), t("fmt-name"))).to be_empty
  end
end
