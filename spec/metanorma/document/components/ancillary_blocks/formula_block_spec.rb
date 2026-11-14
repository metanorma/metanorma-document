# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::Components::AncillaryBlocks::FormulaBlock do
  # Formula-level bare <fn>: a footnote reference appearing directly inside
  # <formula>, not nested in a stem or paragraph. Documented as a model gap
  # in metanorma/metanorma-iso#1739 (MHTML parity program): the unmapped
  # <fn> was dropped at model parse and never reached any renderer.
  let(:formula_xml) do
    <<~XML
      <formula id="formulaC-1" unnumbered="true">
        <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>t</mi></math></stem>
        <fn reference="1" id="fnC-1">
          <p id="_fn1p">The time was estimated to be 18,2 min for this example.</p>
        </fn>
        <dl>
          <dt>
            <p id="_d1t">t</p>
          </dt>
          <dd>
            <p id="_d1d">cooking time, expressed in minutes</p>
          </dd>
        </dl>
      </formula>
    XML
  end

  describe "bare fn reference" do
    it "declares an fn attribute" do
      expect(described_class.attributes.key?(:fn)).to be(true)
    end

    it "parses the footnote reference" do
      formula = described_class.from_xml(formula_xml)

      expect(formula.fn).to be_a(Array)
      expect(formula.fn.length).to eq(1)
      expect(formula.fn.first.id).to eq("fnC-1")
      expect(formula.fn.first.reference).to eq("1")
    end

    it "keeps the footnote body paragraphs" do
      formula = described_class.from_xml(formula_xml)

      body = formula.fn.first.p
      expect(body.length).to eq(1)
      expect(body.first.text.join).to include("estimated to be 18,2 min")
    end

    it "round-trips the fn element with its attributes and body" do
      formula = described_class.from_xml(formula_xml)
      out = formula.to_xml
      doc = Nokogiri::XML(out)
      fn = doc.at_xpath("//*[local-name() = 'formula']/*[local-name() = 'fn']")

      expect(fn).not_to be_nil
      expect(fn["id"]).to eq("fnC-1")
      expect(fn["reference"]).to eq("1")
      expect(fn.at_xpath(".//*[local-name() = 'p']").text)
        .to eq("The time was estimated to be 18,2 min for this example.")
    end

    it "round-trips alongside the stem and dl without dropping either" do
      formula = described_class.from_xml(formula_xml)
      doc = Nokogiri::XML(formula.to_xml)
      f = doc.at_xpath("//*[local-name() = 'formula']")

      expect(f.at_xpath("./*[local-name() = 'stem']")).not_to be_nil
      expect(f.at_xpath("./*[local-name() = 'dl']")).not_to be_nil
    end

    it "accepts multiple formula-level footnotes" do
      xml = formula_xml.sub("<dl>",
                            "<fn reference=\"2\" id=\"fnC-2\"><p>Second note.</p></fn><dl>")
      formula = described_class.from_xml(xml)

      expect(formula.fn.map(&:id)).to eq(%w(fnC-1 fnC-2))
    end
  end

  describe "presentation form" do
    it "parses a bare fn reference out of a presentation formula" do
      xml = <<~XML
        <formula id="_fdcdc95f" semx-id="_fdcdc95f">
          <fmt-stem type="MathML"><semx element="stem" source="_8cba98a7"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>R</mi></math></semx></fmt-stem>
          <fn reference="3" id="_fn3" hiddenref="false">
            <p>Parboiled rice is excluded from this measurement.</p>
          </fn>
        </formula>
      XML
      formula = described_class.from_xml(xml)

      expect(formula.fn.length).to eq(1)
      expect(formula.fn.first.reference).to eq("3")
      expect(formula.fmt_stem).not_to be_nil
      expect(formula.to_xml).to include("<fn")
    end
  end
end
