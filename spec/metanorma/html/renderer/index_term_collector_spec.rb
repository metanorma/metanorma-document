# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/component/index_term_collector"

RSpec.describe Metanorma::Html::Component::IndexTermCollector do
  subject(:collector) { described_class.new }

  describe "#empty?" do
    it "is true initially" do
      expect(collector).to be_empty
    end

    it "is false after adding a term" do
      collector.add(primary: "Rice")
      expect(collector).not_to be_empty
    end
  end

  describe "#sorted_groups" do
    it "groups by first letter" do
      collector.add(primary: "Barley", target_id: "sec1")
      collector.add(primary: "Alpha", target_id: "sec2")
      collector.add(primary: "Beta", target_id: "sec3")

      groups = collector.sorted_groups
      expect(groups.map(&:letter)).to eq(%w[A B])
    end

    it "merges duplicate primaries" do
      collector.add(primary: "Rice", target_id: "sec1")
      collector.add(primary: "rice", target_id: "sec2")

      groups = collector.sorted_groups
      expect(groups.length).to eq(1)
      expect(groups.first.entries.length).to eq(1)
      expect(groups.first.entries.first.locators.length).to eq(2)
    end

    it "supports secondary and tertiary terms" do
      collector.add(primary: "Grain", secondary: "Wheat", tertiary: "Durum",
                    target_id: "sec1")

      groups = collector.sorted_groups
      expect(groups.length).to eq(1)
      entry = groups.first.entries.first
      expect(entry.children.length).to eq(1)
      expect(entry.children.first.children.length).to eq(1)
    end
  end
end
