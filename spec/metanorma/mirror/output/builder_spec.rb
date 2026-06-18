# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"
require "tmpdir"
require "fileutils"

RSpec.describe Metanorma::Mirror::Output::Builder do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end

  describe "#initialize" do
    it "stores xml_path, output_path, format, and options" do
      builder = described_class.new(
        xml_path: "/tmp/in.xml",
        output_path: "/tmp/out.html",
        format: :inline,
        flavor: "iso",
      )
      builder.xml_path.should eq("/tmp/in.xml")
      builder.output_path.should eq("/tmp/out.html")
      builder.format.should eq(:inline)
      builder.options[:flavor].should eq("iso")
    end

    it "defaults format to :inline" do
      builder = described_class.new(xml_path: "/tmp/in.xml", output_path: "/tmp/out.html")
      builder.format.should eq(:inline)
    end

    it "stores id_strategy in options" do
      strategy = Metanorma::Mirror::IdStrategy::Positional.new
      builder = described_class.new(
        xml_path: "/tmp/in.xml",
        output_path: "/tmp/out.html",
        id_strategy: strategy,
      )
      builder.options[:id_strategy].should eq(strategy)
    end
  end

  describe "#build" do
    it "raises ArgumentError for unknown formats" do
      builder = described_class.new(
        xml_path: xml_path,
        output_path: "/tmp/out.html",
        format: :nonexistent,
      )
      -> { builder.build }.should raise_error(ArgumentError, /Unknown format/)
    end

    it "produces an HTML file via the inline format" do
      Dir.mktmpdir do |dir|
        output = File.join(dir, "out.html")
        builder = described_class.new(
          xml_path: xml_path,
          output_path: output,
          format: :inline,
          flavor: "iso",
        )
        result = builder.build
        result.should eq(output)
        File.exist?(output).should be(true)
        content = File.read(output)
        content.should include("<!DOCTYPE html>")
        content.should include("window.METANORMA_DATA")
      end
    end

    it "forwards id_strategy to the pipeline (positional IDs in output)" do
      Dir.mktmpdir do |dir|
        output = File.join(dir, "positional.html")
        builder = described_class.new(
          xml_path: xml_path,
          output_path: output,
          format: :inline,
          flavor: "iso",
          id_strategy: Metanorma::Mirror::IdStrategy::Positional.new,
        )
        builder.build
        content = File.read(output)
        content.should match(/"sec-\d/)
      end
    end

    it "defaults to Preserve strategy when no id_strategy provided" do
      Dir.mktmpdir do |dir|
        output = File.join(dir, "preserve.html")
        builder = described_class.new(
          xml_path: xml_path,
          output_path: output,
          format: :inline,
          flavor: "iso",
        )
        builder.build
        content = File.read(output)
        content.should include("window.METANORMA_DATA")
      end
    end
  end
end
