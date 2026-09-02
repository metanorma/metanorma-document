# frozen_string_literal: true

require "spec_helper"

# A bare `xml do` redeclaration in a TableCell subclass drops every
# parent map_element (lutaml-model does not inherit mappings) — the
# metanorma-document#51 root cause: stems inside <td> parsed hollow and
# linearized row text concatenated MathML fragments.
RSpec.describe Metanorma::Document::Components::Tables do
  it "parses stems inside td as typed inline content" do
    cell = described_class::TextTableCell.from_xml(
      '<td id="_c1">n <stem type="AsciiMath"><asciimath>n_{"LC"}</asciimath>' \
      "</stem> max</td>"
    )

    expect(cell.id).to eq("_c1")
    expect(cell.stem).not_to be_empty

    extracted = Metanorma::Document::PlainText.call(cell)
    expect(extracted).to eq('n n_{"LC"} max')
  end

  it "parses th inline emphasis (header cells share the mapping)" do
    th = described_class::HeaderTableCell.from_xml("<th>MPE <em>max</em></th>")
    expect(th.em).not_to be_empty
  end

  it "keeps stems through serialization round-trip" do
    cell = described_class::TextTableCell.from_xml(
      '<td><stem type="AsciiMath"><asciimath>v</asciimath></stem></td>'
    )
    expect(cell.to_xml).to include("stem")
  end
end
