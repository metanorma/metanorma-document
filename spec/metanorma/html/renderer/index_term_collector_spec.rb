# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/component/index_term_collector"

RSpec.describe Metanorma::Html::Component::IndexTermCollector do
  subject(:collector) { described_class.new }

  describe "#empty?" do
    it "is true initially" do
      collector.should be_empty
    end

    it "is false after adding a term" do
      collector.add(primary: "Rice")
      collector.should_not be_empty
    end
  end

  describe "#sorted_groups" do
    it "groups by first letter" do
      collector.add(primary: "Barley", target_id: "sec1")
      collector.add(primary: "Alpha", target_id: "sec2")
      collector.add(primary: "Beta", target_id: "sec3")

      groups = collector.sorted_groups
      groups.map(&:letter).should eq(%w[A B])
    end

    it "merges duplicate primaries" do
      collector.add(primary: "Rice", target_id: "sec1")
      collector.add(primary: "rice", target_id: "sec2")

      groups = collector.sorted_groups
      groups.length.should eq(1)
      groups.first.entries.length.should eq(1)
      groups.first.entries.first.locators.length.should eq(2)
    end

    it "supports secondary and tertiary terms" do
      collector.add(primary: "Grain", secondary: "Wheat", tertiary: "Durum", target_id: "sec1")

      groups = collector.sorted_groups
      groups.length.should eq(1)
      entry = groups.first.entries.first
      entry.children.length.should eq(1)
      entry.children.first.children.length.should eq(1)
    end
  end
end
