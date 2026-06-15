# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "tmpdir"
require "fileutils"

RSpec.describe Metanorma::Mirror::Output::Formats::InlineFormat do
  let(:xml_path) do
    File.expand_path("../../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end

  let(:pipeline) do
    Metanorma::Mirror::Output::Pipeline.new(xml_path: xml_path, flavor: "iso")
  end

  let(:guide) { pipeline.process }

  describe "#write" do
    it "writes a complete HTML document with data and SSR body" do
      Dir.mktmpdir do |dir|
        output = File.join(dir, "out.html")
        formatter = described_class.new
        result = formatter.write(output, guide, title: "My Doc")

        result.should eq(output)
        content = File.read(output)
        content.should include("<!DOCTYPE html>")
        content.should include("<title>My Doc</title>")
        content.should include("window.METANORMA_DATA")
        content.should include("<body>")
      end
    end

    it "creates the output directory if missing" do
      Dir.mktmpdir do |dir|
        nested = File.join(dir, "a", "b", "out.html")
        formatter = described_class.new
        formatter.write(nested, guide, title: "X")
        File.exist?(nested).should be(true)
      end
    end
  end

  describe "Formats.lookup" do
    it "returns the InlineFormat class for :inline" do
      Metanorma::Mirror::Output::Formats.lookup(:inline).should eq(described_class)
    end

    it "returns nil for unknown formats" do
      Metanorma::Mirror::Output::Formats.lookup(:nonexistent).should be_nil
    end
  end

  describe "Formats.register" do
    after do
      Metanorma::Mirror::Output::Formats.unregister(:test_format)
    end

    it "allows new formats to be registered" do
      custom_class = Class.new(described_class)
      Metanorma::Mirror::Output::Formats.register(:test_format, custom_class)
      Metanorma::Mirror::Output::Formats.lookup(:test_format).should eq(custom_class)
    end
  end
end
