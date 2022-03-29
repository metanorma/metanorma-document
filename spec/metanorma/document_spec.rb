# frozen_string_literal: true

RSpec.describe Metanorma::Document do
  it "has a version number" do
    Metanorma::Document::VERSION.should_not be nil
  end

  describe ".from_xml" do
    let(:basic_path) { fixture_path("basic") }
    let(:top_class) { Metanorma::Document::Top }

    it "can parse a simple document from string" do
      Metanorma::Document.from_xml(File.read(basic_path)).class.should be top_class
      Metanorma::Document(File.read(basic_path)).class.should be top_class
    end

    it "can parse a simple document from a File object" do
      Metanorma::Document.from_xml(File.open(basic_path)).class.should be top_class
      Metanorma::Document(File.open(basic_path)).class.should be top_class
    end

    it "can parse a simple document from a Nokogiri object" do
      ng = Nokogiri::XML(basic_path)

      Metanorma::Document.from_xml(ng).class.should be top_class
      Metanorma::Document(ng).class.should be top_class
    end
  end
end
