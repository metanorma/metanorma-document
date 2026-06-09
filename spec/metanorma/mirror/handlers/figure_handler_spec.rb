# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"

RSpec.describe Metanorma::Mirror::Handlers::Figure do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::MetanormaToMirror.new(registry: registry,
                                              id_strategy: id_strategy)
  end

  def parse_figure(xml)
    Metanorma::Document::Components::AncillaryBlocks::FigureBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns a Figure hash" do
      el = parse_figure("<figure id='f1'><image src='test.png'/></figure>")
      result = described_class.call(el, context: context)
      result["type"].should eq("figure")
    end

    it "extracts image with src" do
      el = parse_figure("<figure id='f1'><image src='test.png' height='100' width='200'/></figure>")
      result = described_class.call(el, context: context)
      img = (result["content"] || []).find { |n| n["type"] == "image" }
      img.should_not be_nil
      img["attrs"]["src"].should eq("test.png")
      img["attrs"]["height"].should eq("100")
      img["attrs"]["width"].should eq("200")
    end

    it "extracts alt text from image" do
      el = parse_figure("<figure id='f1'><image src='x.png' alt='Diagram'/></figure>")
      result = described_class.call(el, context: context)
      img = (result["content"] || []).find { |n| n["type"] == "image" }
      img["attrs"]["alt"].should eq("Diagram")
    end

    it "extracts figure title from name" do
      el = parse_figure("<figure id='f1'><name>Fig 1</name></figure>")
      result = described_class.call(el, context: context)
      result["attrs"]["title"].should eq("Fig 1")
    end
  end

  describe ".figure_attrs" do
    it "compacts nil values" do
      el = parse_figure("<figure id='f1'></figure>")
      attrs = described_class.figure_attrs(el)
      attrs.should_not have_key(:unnumbered)
      attrs.should_not have_key(:width)
    end
  end
end
