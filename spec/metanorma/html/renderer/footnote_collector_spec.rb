# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/component/footnote_collector"

RSpec.describe Metanorma::Html::Component::FootnoteCollector do
  subject(:collector) { described_class.new }

  def mock_fn(id:, reference:, p: [])
    Struct.new(:id, :reference, :p, :fmt_fn_label, keyword_init: true).new(
      id: id, reference: reference, p: p, fmt_fn_label: nil,
    )
  end

  describe "#register" do
    it "returns sequential numbers" do
      n1 = collector.register(mock_fn(id: "fn1", reference: "a"))
      n2 = collector.register(mock_fn(id: "fn2", reference: "b"))
      expect(n1).to eq(1)
      expect(n2).to eq(2)
    end

    it "deduplicates by reference" do
      n1 = collector.register(mock_fn(id: "fn1", reference: "a"))
      n2 = collector.register(mock_fn(id: "fn1-dup", reference: "a"))
      expect(n1).to eq(1)
      expect(n2).to eq(1)
    end
  end

  describe "#empty?" do
    it "is true initially" do
      expect(collector).to be_empty
    end

    it "is false after registering" do
      collector.register(mock_fn(id: "fn1", reference: "a"))
      expect(collector).not_to be_empty
    end
  end

  describe "#to_a" do
    it "returns FootnoteEntry structs" do
      collector.register(mock_fn(id: "fn1", reference: "a"))
      entries = collector.to_a
      expect(entries.length).to eq(1)
      expect(entries.first.number).to eq(1)
      expect(entries.first.reference).to eq("a")
    end
  end
end
