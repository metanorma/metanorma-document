# frozen_string_literal: true

require "rspec"
require "nokogiri"
require_relative "../../../../lib/metanorma/document"

RSpec.describe "Native presentation label data" do
  let(:inline) { Metanorma::Document::Components::Inline }
  let(:data_class) { inline::FmtLadlLabelData }

  before do
    inline::FmtXrefLabelElement
    Lutaml::Model::Config.xml_adapter_type = :nokogiri
  end

  it "preserves all six typed fields through native XML serialization" do
    data = data_class.new(local: "NOTE 1", global: "Clause 2, NOTE 1", value: "1",
                          direction: "ltr", global_direction: "rtl", labeller: "note_labeller")
    parsed = data_class.from_xml(data.to_xml)
    expect(%i[local global value direction global_direction labeller].map { |key| parsed.public_send(key) })
      .to eq(["NOTE 1", "Clause 2, NOTE 1", "1", "ltr", "rtl", "note_labeller"])
    expect(parsed).to be_a(inline::RenderedDisplay)
  end

  it "adds no metadata when parsing and serializing an existing mixed label" do
    xml = '<fmt-xref-label>before<semx element="autonum" source="c1">2</semx><span class="delimiter">.</span>after</fmt-xref-label>'
    label = inline::FmtXrefLabelElement.from_xml(xml)
    expect(label.fmt_ladl_label_data).to be_nil
    expect(Nokogiri::XML(label.to_xml).root.children.map(&:to_xml))
      .to eq(Nokogiri::XML(xml).root.children.map(&:to_xml))
  end

  it "retains existing inline order alongside optional metadata" do
    xml = '<fmt-xref-label>before<semx element="autonum" source="c1">2</semx><span class="delimiter">.</span>after<fmt-ladl-label-data local="2" global="Clause 2" value="2" labeller="clause"/></fmt-xref-label>'
    label = inline::FmtXrefLabelElement.from_xml(xml)
    reparsed = inline::FmtXrefLabelElement.from_xml(label.to_xml)
    expect(reparsed.fmt_ladl_label_data.global).to eq("Clause 2")
    without_data = ->(source) {
      doc = Nokogiri::XML(source)
      doc.xpath("//fmt-ladl-label-data").remove
      doc.root.children.map(&:to_xml)
    }
    expect(without_data.call(label.to_xml)).to eq(without_data.call(xml))
  end

  it "retains footnote tab and mixed content with typed metadata" do
    xml = '<fmt-fn-label>before<span class="label">a</span><tab/>after<fmt-ladl-label-data local="a" value="a" labeller="fn"/></fmt-fn-label>'
    label = inline::FmtFnLabelElement.from_xml(xml)
    parsed = inline::FmtFnLabelElement.from_xml(label.to_xml)
    expect(parsed.fmt_ladl_label_data.local).to eq("a")
    expect(parsed.tab.length).to eq(1)
    expect(Nokogiri::XML(label.to_xml).root.text).to eq("beforeaafter")
  end
end
