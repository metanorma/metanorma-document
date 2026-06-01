# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Relaton-bib integration" do
  describe Metanorma::Document::Relaton::Phone do
    it "inherits from Relaton::Bib::Phone" do
      described_class.ancestors.should include(Relaton::Bib::Phone)
    end

    it "parses XML correctly" do
      phone = described_class.from_xml('<phone type="work">+1-555-1234</phone>')
      phone.type.should eq("work")
      phone.content.should eq("+1-555-1234")
    end
  end

  describe Metanorma::Document::Relaton::PriceType do
    it "inherits from Relaton::Bib::Price" do
      described_class.ancestors.should include(Relaton::Bib::Price)
    end

    it "parses XML correctly" do
      price = described_class.from_xml('<price currency="USD">25.00</price>')
      price.currency.should eq("USD")
      price.content.should eq("25.00")
    end
  end

  describe Metanorma::Document::Relaton::BibItemLocality do
    it "inherits from Relaton::Bib::Locality" do
      described_class.ancestors.should include(Relaton::Bib::Locality)
    end

    it "has type, reference_from, and reference_to attributes" do
      attrs = described_class.attributes.keys
      attrs.should include(:type, :reference_from, :reference_to)
    end
  end

  describe Metanorma::Document::Relaton::Edition do
    it "inherits from Relaton::Bib::Edition" do
      described_class.ancestors.should include(Relaton::Bib::Edition)
    end

    it "parses XML with extra language attribute" do
      ed = described_class.from_xml('<edition number="1" language="en">1st</edition>')
      ed.number.should eq("1")
      ed.language.should eq("en")
      ed.content.should eq("1st")
    end
  end
end
