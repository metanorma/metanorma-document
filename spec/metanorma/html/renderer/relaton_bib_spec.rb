# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Relaton-bib integration" do
  describe Metanorma::Document::Relaton::Phone do
    it "inherits from Relaton::Bib::Phone" do
      expect(described_class.ancestors).to include(Relaton::Bib::Phone)
    end

    it "parses XML correctly" do
      phone = described_class.from_xml('<phone type="work">+1-555-1234</phone>')
      expect(phone.type).to eq("work")
      expect(phone.content).to eq("+1-555-1234")
    end
  end

  describe Metanorma::Document::Relaton::PriceType do
    it "inherits from Relaton::Bib::Price" do
      expect(described_class.ancestors).to include(Relaton::Bib::Price)
    end

    it "parses XML correctly" do
      price = described_class.from_xml('<price currency="USD">25.00</price>')
      expect(price.currency).to eq("USD")
      expect(price.content).to eq("25.00")
    end
  end

  describe Metanorma::Document::Relaton::BibItemLocality do
    it "inherits from Relaton::Bib::Locality" do
      expect(described_class.ancestors).to include(Relaton::Bib::Locality)
    end

    it "has type, reference_from, and reference_to attributes" do
      attrs = described_class.attributes.keys
      expect(attrs).to include(:type, :reference_from, :reference_to)
    end
  end

  describe Metanorma::Document::Relaton::Edition do
    it "inherits from Relaton::Bib::Edition" do
      expect(described_class.ancestors).to include(Relaton::Bib::Edition)
    end

    it "parses XML with extra language attribute" do
      ed = described_class.from_xml('<edition number="1" language="en">1st</edition>')
      expect(ed.number).to eq("1")
      expect(ed.language).to eq("en")
      expect(ed.content).to eq("1st")
    end
  end
end
