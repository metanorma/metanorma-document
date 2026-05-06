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
      n1.should eq(1)
      n2.should eq(2)
    end

    it "deduplicates by reference" do
      n1 = collector.register(mock_fn(id: "fn1", reference: "a"))
      n2 = collector.register(mock_fn(id: "fn1-dup", reference: "a"))
      n1.should eq(1)
      n2.should eq(1)
    end
  end

  describe "#empty?" do
    it "is true initially" do
      collector.should be_empty
    end

    it "is false after registering" do
      collector.register(mock_fn(id: "fn1", reference: "a"))
      collector.should_not be_empty
    end
  end

  describe "#to_a" do
    it "returns FootnoteEntry structs" do
      collector.register(mock_fn(id: "fn1", reference: "a"))
      entries = collector.to_a
      entries.length.should eq(1)
      entries.first.number.should eq(1)
      entries.first.reference.should eq("a")
    end
  end
end
