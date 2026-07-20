# frozen_string_literal: true

require_relative "../../spec_helper"

require "metanorma/un_document"

RSpec.describe Metanorma::UnDocument::Blocks::UnAdmonitionBlock do
  let(:register) { Lutaml::Model::GlobalRegister.lookup(:un_document) }

  it "is substituted for the base AdmonitionBlock in the UN register" do
    expect(register.substitutable?(
             Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
           )).to be true
  end

  it "parses admonitions as UnAdmonitionBlock through the UN root" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/un" type="presentation">
        <sections><clause id="_c">
          <admonition id="_ad" type="warning"><p id="_p">Warn</p></admonition>
        </clause></sections>
      </metanorma>
    XML
    doc = Metanorma::UnDocument::Root.from_xml(xml)
    adm = doc.sections.clause.first.admonitions.first
    expect(adm).to be_a(described_class)
    expect(adm.type).to eq("warning")
  end

  it "parses the widened UN admonition body with notes after it" do
    xml = <<~XML
      <admonition id="_ad" type="caution" unnumbered="true">
        <name>Safety</name>
        <p id="_p1">Text</p>
        <table id="_t"><tbody><tr><td>x</td></tr></tbody></table>
        <ol id="_o"><li><p>i</p></li></ol>
        <ul id="_u"><li><p>i</p></li></ul>
        <dl id="_d"><dt>t</dt><dd><p>d</p></dd></dl>
        <figure id="_f"><image id="_i" src="a.png"/></figure>
        <quote id="_q"><p id="_qp">q</p></quote>
        <sourcecode id="_s">code</sourcecode>
        <example id="_e"><p id="_ep">e</p></example>
        <note id="_n"><p>after body</p></note>
      </admonition>
    XML
    adm = described_class.from_xml(xml)
    expect(adm.unnumbered).to be(true)
    expect(adm.paragraphs.length).to eq(1)
    expect(adm.tables.length).to eq(1)
    expect(adm.ordered_lists.length).to eq(1)
    expect(adm.unordered_lists.length).to eq(1)
    expect(adm.definition_lists.length).to eq(1)
    expect(adm.figures.length).to eq(1)
    expect(adm.quote_blocks.length).to eq(1)
    expect(adm.sourcecode_blocks.length).to eq(1)
    expect(adm.examples.length).to eq(1)
    expect(adm.notes.length).to eq(1)
  end

  it "round-trips body order and trailing notes" do
    xml = <<~XML
      <admonition id="_ad" type="important">
        <p id="_p1">First</p>
        <ul id="_u"><li><p>item</p></li></ul>
        <p id="_p2">Second</p>
        <note id="_n"><p>trailing note</p></note>
      </admonition>
    XML
    adm = described_class.from_xml(xml)
    rt = Nokogiri::XML(adm.to_xml)
    rt.remove_namespaces!
    children = rt.at_css("admonition").children.select(&:element?).map(&:name)
    expect(children).to eq(%w[p ul p note])
  end

  it "restricts type to the five UN AdmonitionType values" do
    expect(described_class.attributes[:type].options[:values]).to(
      contain_exactly("danger", "caution", "warning", "important",
                      "safety precautions"),
    )
  end

  it "flags admonition types the UN grammar forbids on validation" do
    adm = described_class.from_xml(
      '<admonition id="_ad" type="editorial"><p>t</p></admonition>',
    )
    errors = adm.validate
    expect(errors.length).to eq(1)
    expect(errors.first).to be_a(Lutaml::Model::InvalidValueError)
  end

  it "accepts every UN-legal admonition type" do
    %w[danger caution warning important].each do |type|
      adm = described_class.from_xml(
        "<admonition id=\"_ad\" type=\"#{type}\"><p>t</p></admonition>",
      )
      expect(adm.type).to eq(type)
    end
    adm = described_class.from_xml(
      '<admonition id="_ad" type="safety precautions"><p>t</p></admonition>',
    )
    expect(adm.type).to eq("safety precautions")
  end
end
