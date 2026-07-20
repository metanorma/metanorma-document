# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Metadata do
  describe ".title_from_bibdata" do
    let(:bibdata_class) { Struct.new(:title) }

    it "returns nil for nil input" do
      expect(described_class.title_from_bibdata(nil)).to be_nil
    end

    it "extracts a string title" do
      bibdata = bibdata_class.new("Hello World")
      expect(described_class.title_from_bibdata(bibdata)).to eq("Hello World")
    end

    it "extracts the first string from an array of titles" do
      bibdata = bibdata_class.new(["First", "Second"])
      expect(described_class.title_from_bibdata(bibdata)).to eq("First")
    end

    it "returns nil for an empty title array" do
      bibdata = bibdata_class.new([])
      expect(described_class.title_from_bibdata(bibdata)).to be_nil
    end

    it "returns nil when title is nil" do
      bibdata = bibdata_class.new(nil)
      expect(described_class.title_from_bibdata(bibdata)).to be_nil
    end

    it "coerces non-string scalars to string" do
      bibdata = bibdata_class.new(42)
      expect(described_class.title_from_bibdata(bibdata)).to eq("42")
    end
  end
end
