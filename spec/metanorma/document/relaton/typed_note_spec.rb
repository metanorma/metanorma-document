# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Metanorma::Document::Relaton::TypedNote do
  it "maps structured p children of a display note" do
    xml = <<~XML
      <note type="display">
        <p id="_n1">The identification of this document is deliberate.</p>
        <p>Second annotation paragraph.</p>
      </note>
    XML

    note = described_class.from_xml(xml)

    expect(note.type).to eq("display")
    expect(note.p.size).to eq(2)
    expect(note.p.first.text).to eq(["The identification of this document is deliberate."])
    expect(note.p.last.text).to eq(["Second annotation paragraph."])
  end

  it "keeps plain-text notes reachable alongside structured ones" do
    xml = <<~XML
      <note type="display" format="text/plain">Plain text annotation.</note>
    XML

    note = described_class.from_xml(xml)

    expect(note.format).to eq("text/plain")
    expect(note.text).to eq(["Plain text annotation."])
  end

  it "parses structured display notes through a references-section bibitem" do
    xml = <<~XML
      <references id="_refs" normative="true">
        <bibitem id="RFC2100">
          <note type="display"><p id="_n1">The identification of this RFC is deliberate.</p></note>
        </bibitem>
      </references>
    XML

    section = Metanorma::StandardDocument::Sections::StandardReferencesSection.from_xml(xml)
    note = section.references.first.note.first

    expect(note).to be_a(described_class)
    expect(note.p.first.text).to eq(["The identification of this RFC is deliberate."])
  end
end
