# frozen_string_literal: true

RSpec.describe Metanorma::Document do
  it "has a version number" do
    Metanorma::Document::VERSION.should_not be_nil
  end

  describe ".from_file" do
    let(:basic_path) { fixture_path("basic") }

    it "raises NotImplementedError as BasicDocument cannot parse XML directly" do
      lambda {
        described_class.from_file(basic_path)
      }.should raise_error(NotImplementedError)
    end
  end
end

RSpec.describe "Document flavors" do
  describe "Document::Root" do
    it "is defined" do
      defined?(Metanorma::Document::Root).should be_truthy
    end

    it "is a class" do
      Metanorma::Document::Root.class.should eq(Class)
    end
  end

  describe "StandardDocument" do
    it "is defined" do
      defined?(Metanorma::StandardDocument).should be_truthy
    end
  end

  describe "IsoDocument" do
    it "has Root" do
      defined?(Metanorma::IsoDocument::Root).should be_truthy
    end
  end
end
