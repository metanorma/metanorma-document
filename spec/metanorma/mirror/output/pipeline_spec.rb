# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Output::Pipeline do
  describe "default configuration" do
    it "uses default steps [ParseXml, TransformMirror, AttachMetadata]" do
      pipeline = described_class.new(xml_path: "/tmp/test.xml")
      pipeline.steps.size.should eq(3)
      pipeline.steps[0].should eq(described_class::Steps::ParseXml)
      pipeline.steps[1].should eq(described_class::Steps::TransformMirror)
      pipeline.steps[2].should eq(described_class::Steps::AttachMetadata)
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
      pipeline.steps.size.should eq(1)
    end
  end

  describe "id_strategy threading" do
    it "passes id_strategy through PipelineContext" do
      strategy = Metanorma::Mirror::IdStrategy::Positional.new
      pipeline = described_class.new(xml_path: "/tmp/test.xml",
                                     id_strategy: strategy)
      pipeline.context.id_strategy.should eq(strategy)
    end

    it "defaults id_strategy to nil" do
      pipeline = described_class.new(xml_path: "/tmp/test.xml")
      pipeline.context.id_strategy.should be_nil
    end
  end

  describe Metanorma::Mirror::Output::PipelineContext do
    it "accepts id_strategy as keyword argument" do
      strategy = Metanorma::Mirror::IdStrategy::Preserve.new
      ctx = described_class.new(xml_path: "/tmp/test.xml",
                                id_strategy: strategy)
      ctx.id_strategy.should eq(strategy)
    end

    it "defaults id_strategy to nil" do
      ctx = described_class.new(xml_path: "/tmp/test.xml")
      ctx.id_strategy.should be_nil
    end
  end
end
