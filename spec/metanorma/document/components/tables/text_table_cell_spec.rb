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
      "</stem> max</td>",
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
      '<td><stem type="AsciiMath"><asciimath>v</asciimath></stem></td>',
    )
    expect(cell.to_xml).to include("stem")
  end

  # #51: a stem carries the MathML rendering AND the AsciiMath source
  # of one expression — linearizing both concatenates duplicates.
  it "linearizes one stem form when math and asciimath both parse" do
    cell = described_class::TextTableCell.from_xml(
      '<td>Class C, <stem type="MathML"><math><mstyle><mn>3000</mn>' \
      "</mstyle></math><asciimath>3000</asciimath></stem> intervals</td>",
    )

    expect(Metanorma::Document::PlainText.call(cell))
      .to eq("Class C, 3000 intervals")
  end

  it "unwraps the quoted unitsml macro to the unit symbol" do
    cell = described_class::TextTableCell.from_xml(
      '<td>(<stem type="MathML"><math><mrow><mi>mV</mi></mrow></math>' \
      '<asciimath>"unitsml(mV/V)"</asciimath></stem> or counts)</td>',
    )

    expect(Metanorma::Document::PlainText.call(cell))
      .to eq("(mV/V or counts)")
  end

  # AsciiMath spells the plus-minus operator "pm"; display text carries
  # the glyph (the OIML MPE tables state tolerances as stem:[pm 0.10 %]).
  it "renders the AsciiMath uncertainty operator as the ± glyph" do
    cell = described_class::TextTableCell.from_xml(
      '<td><stem type="AsciiMath"><asciimath>pm 0.10 %</asciimath></stem></td>',
    )

    expect(Metanorma::Document::PlainText.call(cell)).to eq("± 0.10 %")
  end

  it "renders the minus-plus operator as ∓" do
    cell = described_class::TextTableCell.from_xml(
      '<td><stem type="AsciiMath"><asciimath>mp 2 mg</asciimath></stem></td>',
    )

    expect(Metanorma::Document::PlainText.call(cell)).to eq("∓ 2 mg")
  end

  it "maps the LaTeX \\pm spelling too" do
    cell = described_class::TextTableCell.from_xml(
      '<td><stem type="LatexMath"><latexmath>\pm 70 e</latexmath></stem></td>',
    )

    expect(Metanorma::Document::PlainText.call(cell)).to include("± 70")
  end

  it "keeps a pm that is part of a larger word" do
    cell = described_class::TextTableCell.from_xml(
      '<td><stem type="AsciiMath"><asciimath>rpm 5</asciimath></stem></td>',
    )

    expect(Metanorma::Document::PlainText.call(cell)).to eq("rpm 5")
  end

  it "falls back to the MathML token walk for math-only stems" do
    cell = described_class::TextTableCell.from_xml(
      "<td><stem type=\"MathML\"><math><mi>v</mi></math></stem></td>",
    )

    expect(Metanorma::Document::PlainText.call(cell)).to eq("v")
  end

  # Presentation XML carries the semantic stem and its rendered
  # fmt-stem twin — the twin must not duplicate the math text.
  it "skips the fmt-stem rendered twin when the semantic stem parsed" do
    cell = described_class::TextTableCell.from_xml(
      '<td><stem type="AsciiMath"><asciimath>x</asciimath></stem>' \
      '<fmt-stem type="AsciiML"><semx element="stem" source="_s1">' \
      "<asciimath>x</asciimath></semx></fmt-stem></td>",
    )

    expect(Metanorma::Document::PlainText.call(cell)).to eq("x")
  end

  # semx declares stem attributes for stem slices; an autonum slice
  # populates none of them and must keep the plain text walk.
  it "extracts semx autonum fragments that carry no math forms" do
    cell = described_class::TextTableCell.from_xml(
      '<td>see <semx element="autonum" source="_t1">7.2.1</semx></td>',
    )

    expect(Metanorma::Document::PlainText.call(cell)).to eq("see 7.2.1")
  end
end
