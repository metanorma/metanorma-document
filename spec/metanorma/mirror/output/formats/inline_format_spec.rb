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

        expect(result).to eq(output)
        content = File.read(output)
        expect(content).to include("<!DOCTYPE html>")
        expect(content).to include("<title>My Doc</title>")
        expect(content).to include("window.METANORMA_DATA")
        expect(content).to include("<body>")
      end
    end

    it "embeds the classic-rendered document body as SSR content" do
      Dir.mktmpdir do |dir|
        output = File.join(dir, "out.html")
        described_class.new.write(output, guide, title: "My Doc")

        content = File.read(output)
        # Markers of the classic Metanorma::Html renderer, not mirror-IR
        # output: the classic <main> wrapper, its foreword heading, and
        # paragraph text from the ISO fixture.
        expect(content).to include('<main class="main-section">')
        expect(content).to include('<h1 class="foreword-title">Foreword</h1>')
        expect(content).to include(
          "ISO (the International Organization for Standardization)",
        )
      end
    end

    it "raises ArgumentError when the guide carries no source document" do
      guide_without_doc = Metanorma::Mirror::Model::Guide.new(content: nil)
      Dir.mktmpdir do |dir|
        output = File.join(dir, "out.html")
        expect { described_class.new.write(output, guide_without_doc) }
          .to raise_error(ArgumentError, /requires a Guide carrying its source document/)
      end
    end

    it "creates the output directory if missing" do
      Dir.mktmpdir do |dir|
        nested = File.join(dir, "a", "b", "out.html")
        formatter = described_class.new
        formatter.write(nested, guide, title: "X")
        expect(File.exist?(nested)).to be(true)
      end
    end
  end

  describe "Formats.lookup" do
    it "returns the InlineFormat class for :inline" do
      expect(Metanorma::Mirror::Output::Formats.lookup(:inline)).to eq(described_class)
    end

    it "returns nil for unknown formats" do
      expect(Metanorma::Mirror::Output::Formats.lookup(:nonexistent)).to be_nil
    end
  end

  describe "Formats.register" do
    after do
      Metanorma::Mirror::Output::Formats.unregister(:test_format)
    end

    it "allows new formats to be registered" do
      custom_class = Class.new(described_class)
      Metanorma::Mirror::Output::Formats.register(:test_format, custom_class)
      expect(Metanorma::Mirror::Output::Formats.lookup(:test_format)).to eq(custom_class)
    end
  end
end
