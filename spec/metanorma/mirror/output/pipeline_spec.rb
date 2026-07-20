# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Output::Pipeline do
  describe "default configuration" do
    it "uses default steps [ParseXml, TransformMirror, AttachMetadata]" do
      pipeline = described_class.new(xml_path: "/tmp/test.xml")
      expect(pipeline.steps.size).to eq(3)
      expect(pipeline.steps[0]).to eq(described_class::Steps::ParseXml)
      expect(pipeline.steps[1]).to eq(described_class::Steps::TransformMirror)
      expect(pipeline.steps[2]).to eq(described_class::Steps::AttachMetadata)
    end
  end

  describe "custom steps" do
    it "accepts custom step classes" do
      custom_step = Class.new do
        def call(guide, _context)
          guide["custom"] = true
          guide
        end
      end

      pipeline = described_class.new(xml_path: "/tmp/test.xml",
                                     steps: [custom_step])
      expect(pipeline.steps.size).to eq(1)
    end
  end

  describe "id_strategy threading" do
    it "passes id_strategy through PipelineContext" do
      strategy = Metanorma::Mirror::IdStrategy::Positional.new
      pipeline = described_class.new(xml_path: "/tmp/test.xml",
                                     id_strategy: strategy)
      expect(pipeline.context.id_strategy).to eq(strategy)
    end

    it "defaults id_strategy to nil" do
      pipeline = described_class.new(xml_path: "/tmp/test.xml")
      expect(pipeline.context.id_strategy).to be_nil
    end
  end

  describe "#process" do
    it "returns a Guide carrying the parsed source document" do
      xml_path = File.expand_path(
        "../../../fixtures/iso/is/document-en.presentation.xml", __dir__
      )
      guide = described_class.new(xml_path: xml_path, flavor: "iso").process
      expect(guide.document).to be_a(Metanorma::IsoDocument::Root)
    end
  end

  describe Metanorma::Mirror::Output::PipelineContext do
    it "accepts id_strategy as keyword argument" do
      strategy = Metanorma::Mirror::IdStrategy::Preserve.new
      ctx = described_class.new(xml_path: "/tmp/test.xml",
                                id_strategy: strategy)
      expect(ctx.id_strategy).to eq(strategy)
    end

    it "defaults id_strategy to nil" do
      ctx = described_class.new(xml_path: "/tmp/test.xml")
      expect(ctx.id_strategy).to be_nil
    end
  end
end
