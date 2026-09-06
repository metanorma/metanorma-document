# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso/document"

RSpec.describe Metanorma::Mirror::Handlers::Figure do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_figure(xml)
    Metanorma::Document::Components::AncillaryBlocks::FigureBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns a Figure hash" do
      el = parse_figure("<figure id='f1'><image src='test.png'/></figure>")
      result = described_class.call(el, context: context)
      expect(result.type).to eq("figure")
    end

    it "extracts image with src" do
      el = parse_figure("<figure id='f1'><image src='test.png' height='100' width='200'/></figure>")
      result = described_class.call(el, context: context)
      img = (result.content || []).find { |n| n.type == "image" }
      expect(img).not_to be_nil
      expect(img.attrs["src"]).to eq("test.png")
      expect(img.attrs["height"]).to eq("100")
      expect(img.attrs["width"]).to eq("200")
    end

    it "extracts alt text from image" do
      el = parse_figure("<figure id='f1'><image src='x.png' alt='Diagram'/></figure>")
      result = described_class.call(el, context: context)
      img = (result.content || []).find { |n| n.type == "image" }
      expect(img.attrs["alt"]).to eq("Diagram")
    end

    it "extracts figure title from name" do
      el = parse_figure("<figure id='f1'><name>Fig 1</name></figure>")
      result = described_class.call(el, context: context)
      expect(result.attrs["title"]).to eq("Fig 1")
    end
  end

  describe ".figure_attrs" do
    it "compacts nil values" do
      el = parse_figure("<figure id='f1'></figure>")
      attrs = described_class.figure_attrs(el)
      expect(attrs).not_to have_key(:unnumbered)
      expect(attrs).not_to have_key(:width)
    end
  end
end
