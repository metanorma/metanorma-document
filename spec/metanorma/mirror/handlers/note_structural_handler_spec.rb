# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso/document"

RSpec.describe Metanorma::Mirror::Handlers::Note do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                       id_strategy: id_strategy)
  end

  def parse_note(xml)
    Metanorma::Document::Components::Blocks::NoteBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns a Note hash" do
      el = parse_note("<note id='n1'><p>Some note text</p></note>")
      result = described_class.call(el, context: context)
      expect(result.type).to eq("note")
    end

    it "extracts id" do
      el = parse_note("<note id='n1'><p>Text</p></note>")
      result = described_class.call(el, context: context)
      expect(result.attrs["id"]).to eq("n1")
    end

    it "extracts content paragraphs" do
      el = parse_note("<note id='n1'><p>Line 1</p><p>Line 2</p></note>")
      result = described_class.call(el, context: context)
      expect(result.content.size).to eq(2)
      result.content.each { |c| expect(c.type).to eq("paragraph") }
    end

    it "works with no id" do
      el = parse_note("<note><p>Text</p></note>")
      result = described_class.call(el, context: context)
      expect(result.type).to eq("note")
      expect(result.attrs).to be_empty
    end
  end
end
