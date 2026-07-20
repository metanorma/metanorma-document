# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"

RSpec.describe "BUGS.sts 03: FmtStemElement declares mixed_content" do
  it "each_mixed_content yields its semx children" do
    fmt_stem = Metanorma::Document::Components::Inline::FmtStemElement.from_xml(<<~XML)
      <fmt-stem xmlns="https://www.metanorma.org/ns/standoc" type="MathML">
        <semx element="stem" source="s1">
          <math xmlns="http://www.w3.org/1998/Math/MathML">
            <mn>0,7</mn>
          </math>
          <asciimath>0.7</asciimath>
        </semx>
      </fmt-stem>
    XML

    yielded = []
    fmt_stem.each_mixed_content { |n| yielded << n }

    expect(yielded.any?(Metanorma::Document::Components::Inline::SemxElement)).to be(true)
  end

  it "still exposes semx via the typed attribute" do
    fmt_stem = Metanorma::Document::Components::Inline::FmtStemElement.from_xml(<<~XML)
      <fmt-stem xmlns="https://www.metanorma.org/ns/standoc" type="MathML">
        <semx element="stem" source="s1">
          <math xmlns="http://www.w3.org/1998/Math/MathML">
            <mn>0,7</mn>
          </math>
        </semx>
      </fmt-stem>
    XML
    expect(Array(fmt_stem.semx).size).to eq(1)
  end
end
