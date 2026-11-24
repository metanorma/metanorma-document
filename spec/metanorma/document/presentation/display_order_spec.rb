# frozen_string_literal: true

require "spec_helper"
require "isodoc"
require "metanorma-iso"
require "metanorma-itu"
require "nokogiri"

RSpec.describe Metanorma::Document::Presentation::Behaviours::DisplayOrder do
  let(:presentation) { Metanorma::Document::Presentation }
  let(:ns) { "http://riboseinc.com/isoxml" }
  let(:layers) do
    presentation::ProfileLoader.from_file(File.expand_path("../../../fixtures/presentation/behaviours.lml", __dir__))
  end
  # A clause before the terms: the base order puts terms first, ISO keeps
  # document order.
  let(:source) do
    <<~XML
      <iso-standard xmlns="#{ns}"><bibdata type="standard"><title language="en" type="main">T</title><language>en</language><script>Latn</script><ext><doctype>international-standard</doctype></ext></bibdata>
      <preface><foreword id="fw" obligation="informative"><title>Foreword</title><p id="a">x</p></foreword><introduction id="in"><title>Intro</title><p id="b">x</p></introduction></preface>
      <sections><clause id="cl" obligation="normative"><title>Clause</title><p id="e">x</p></clause>
      <terms id="tm" obligation="normative"><title>Terms</title><term id="t1"><preferred><expression><name>x</name></expression></preferred><definition><verbal-definition><p id="d">d</p></verbal-definition></definition></term></terms>
      <clause id="sc" type="scope" obligation="normative"><title>Scope</title><p id="c">x</p></clause></sections>
      <annex id="an" obligation="informative"><title>Annex</title><p id="f">x</p></annex>
      <bibliography><references id="bib" normative="false" obligation="informative"><title>Bibliography</title></references></bibliography>
      </iso-standard>
    XML
  end

  def present(converter)
    Nokogiri::XML(converter.new({}).convert("t", source, true))
  end

  # id => displayorder for the sections the engine is meant to place; the
  # generated table of contents is left out, ranks are compared as order.
  def order_of(doc)
    ids = %w[fw in sc cl tm an bib]
    doc.xpath("//*[@displayorder]").select { |n| ids.include?(n["id"]) }
      .sort_by { |n| n["displayorder"].to_i }.map { |n| n["id"] }
  end

  def engine_order(doc, flavor)
    doc.xpath("//*[@displayorder]").each { |n| n.remove_attribute("displayorder") }
    root = Metanorma::Iso::Document::Root.from_xml(doc.to_xml)
    base = presentation::LayeredProfile.resolve(layers, flavor: flavor)
    out = presentation::Engine.new(profile: presentation::Behaviours.profile(base)).call(root)
    order_of(Nokogiri::XML(out.to_xml(prefix: false).gsub(/\sxmlns="[^"]*"/, "")))
  end

  it "base profile equals isodoc's display order" do
    doc = present(IsoDoc::PresentationXMLConvert)
    want = order_of(doc)
    expect(want).to eq(%w[fw in sc tm cl an bib])
    expect(engine_order(doc, nil)).to eq(want)
  end

  it "the iso flavor delta (main sections in document order) equals the ISO flavor output" do
    doc = present(IsoDoc::Iso::PresentationXMLConvert)
    want = order_of(doc)
    expect(want).to eq(%w[fw in sc cl tm an bib])
    expect(engine_order(doc, "iso")).to eq(want)
  end

  it "the itu flavor delta places boilerplate clauses before the preface, as ITU does" do
    boiler = "<boilerplate><copyright-statement><clause id=\"bp1\"><title>Copyright</title><p id=\"bpp\">x</p></clause></copyright-statement></boilerplate>"
    with_boiler = source.sub("<preface>", "#{boiler}<preface>").gsub("iso-standard", "itu-standard")
    doc = Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new({}).convert("t", with_boiler, true))
    ids = %w[bp1 fw in sc tm cl an bib]
    want = doc.xpath("//*[@displayorder]").select { |n| ids.include?(n["id"]) }
      .sort_by { |n| n["displayorder"].to_i }.map { |n| n["id"] }
    expect(want).to eq(%w[bp1 fw in sc tm cl an bib])
    doc.xpath("//*[@displayorder]").each { |n| n.remove_attribute("displayorder") }
    root = Metanorma::Itu::Document::Root.from_xml(doc.to_xml)
    base = presentation::LayeredProfile.resolve(layers, flavor: "itu")
    out = presentation::Engine.new(profile: presentation::Behaviours.profile(base)).call(root)
    got = Nokogiri::XML(out.to_xml(prefix: false).gsub(/\sxmlns="[^"]*"/, ""))
      .xpath("//*[@displayorder]").select { |n| ids.include?(n["id"]) }
      .sort_by { |n| n["displayorder"].to_i }.map { |n| n["id"] }
    expect(got).to eq(want)
  end

  it "rejects an unknown region with the property named" do
    expect { presentation::Behaviours.rules_for("section_order" => "preface,nowhere") }
      .to raise_error(presentation::ProfileError, /section_order.*unknown: nowhere/)
  end
end
