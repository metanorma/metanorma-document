# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"

RSpec.describe Metanorma::Mirror::Handlers::Paragraph do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_paragraph(xml)
    Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns a Paragraph hash" do
      p = parse_paragraph("<p id='p1'>Hello</p>")
      result = described_class.call(p, context: context)
      expect(result.type).to eq("paragraph")
    end

    it "extracts id" do
      p = parse_paragraph("<p id='p1'>Text</p>")
      result = described_class.call(p, context: context)
      expect(result.attrs["id"]).to eq("p1")
    end

    it "extracts inline content" do
      p = parse_paragraph("<p>Hello <em>world</em></p>")
      result = described_class.call(p, context: context)
      expect(result.content).not_to be_empty
    end
  end
end

RSpec.describe Metanorma::Mirror::Handlers::Admonition do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_admonition(xml)
    Metanorma::Document::Components::MultiParagraph::AdmonitionBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns an Admonition hash" do
      el = parse_admonition("<admonition id='a1' type='warning'><p>Be careful</p></admonition>")
      result = described_class.call(el, context: context)
      expect(result.type).to eq("admonition")
    end

    it "extracts type" do
      el = parse_admonition("<admonition id='a1' type='danger'>Content</admonition>")
      result = described_class.call(el, context: context)
      expect(result.attrs["type"]).to eq("danger")
    end
  end
end

RSpec.describe Metanorma::Mirror::Handlers::Example do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_example(xml)
    Metanorma::Document::Components::AncillaryBlocks::ExampleBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns an Example hash" do
      el = parse_example("<example id='e1'><p>Example text</p></example>")
      result = described_class.call(el, context: context)
      expect(result.type).to eq("example")
    end

    it "extracts id" do
      el = parse_example("<example id='e1'><p>Text</p></example>")
      result = described_class.call(el, context: context)
      expect(result.attrs["id"]).to eq("e1")
    end
  end
end

RSpec.describe Metanorma::Mirror::Handlers::Sourcecode do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_sourcecode(xml)
    Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns a Sourcecode hash" do
      el = parse_sourcecode("<sourcecode id='s1' lang='ruby'>puts 'hello'</sourcecode>")
      result = described_class.call(el, context: context)
      expect(result.type).to eq("sourcecode")
    end

    it "extracts language" do
      el = parse_sourcecode("<sourcecode lang='python'>print(1)</sourcecode>")
      result = described_class.call(el, context: context)
      expect(result.attrs["language"]).to eq("python")
    end
  end
end

RSpec.describe Metanorma::Mirror::Handlers::Formula do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_formula(xml)
    Metanorma::Document::Components::AncillaryBlocks::FormulaBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns a Formula hash" do
      el = parse_formula("<formula id='f1'><stem type='MathML'/></formula>")
      result = described_class.call(el, context: context)
      expect(result.type).to eq("formula")
    end

    it "extracts id" do
      el = parse_formula("<formula id='f1'><stem type='MathML'/></formula>")
      result = described_class.call(el, context: context)
      expect(result.attrs["id"]).to eq("f1")
    end
  end
end

RSpec.describe Metanorma::Mirror::Handlers::Quote do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_quote(xml)
    Metanorma::Document::Components::MultiParagraph::QuoteBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns a Quote hash" do
      el = parse_quote("<quote id='q1'><p>Quoted text</p></quote>")
      result = described_class.call(el, context: context)
      expect(result.type).to eq("quote")
    end

    it "extracts id" do
      el = parse_quote("<quote id='q1'><p>Text</p></quote>")
      result = described_class.call(el, context: context)
      expect(result.attrs["id"]).to eq("q1")
    end
  end
end

RSpec.describe Metanorma::Mirror::Handlers::Review do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_review(xml)
    Metanorma::Document::Components::MultiParagraph::ReviewBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns a Review hash" do
      el = parse_review("<review id='r1' reviewer='John'><p>Review comment</p></review>")
      result = described_class.call(el, context: context)
      expect(result.type).to eq("review")
    end

    it "extracts reviewer" do
      el = parse_review("<review id='r1' reviewer='Jane'>Content</review>")
      result = described_class.call(el, context: context)
      expect(result.attrs["reviewer"]).to eq("Jane")
    end
  end
end
