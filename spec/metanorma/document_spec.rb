# frozen_string_literal: true

RSpec.describe Metanorma::Document do
  it "has a version number" do
    expect(Metanorma::Document::VERSION).not_to be_nil
  end

  describe ".from_file" do
    let(:basic_path) { fixture_path("basic") }

    it "raises NotImplementedError as BasicDocument cannot parse XML directly" do
      expect do
        described_class.from_file(basic_path)
      end.to raise_error(NotImplementedError)
    end
  end
end

RSpec.describe "Document flavors" do
  describe "Document::Root" do
    it "is defined" do
      expect(defined?(Metanorma::Document::Root)).to be_truthy
    end

    it "is a class" do
      expect(Metanorma::Document::Root.class).to eq(Class)
    end
  end

  describe "StandardDocument" do
    it "is defined" do
      expect(defined?(Metanorma::StandardDocument)).to be_truthy
    end
  end

  describe "IsoDocument" do
    it "has Root" do
      expect(defined?(Metanorma::IsoDocument::Root)).to be_truthy
    end
  end
end
