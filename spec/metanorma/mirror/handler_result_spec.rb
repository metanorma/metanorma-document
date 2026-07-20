# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::HandlerResult do
  describe ".none" do
    it "returns a none-result sentinel" do
      result = described_class.none
      expect(result.none?).to be(true)
      expect(result.nodes).to be_nil
    end

    it "is not Ruby nil itself" do
      expect(described_class.none.nil?).to be(false)
    end
  end

  describe "#append_to" do
    it "appends a single node" do
      node = Metanorma::Mirror::Model::Container.new(type: "paragraph")
      result = described_class.new(node)
      content = []
      result.append_to(content)
      expect(content.size).to eq(1)
      expect(content[0]).to eq(node)
    end

    it "concatenates multiple nodes when concat is true" do
      nodes = [
        Metanorma::Mirror::Model::Container.new(type: "paragraph"),
        Metanorma::Mirror::Model::Container.new(type: "note"),
      ]
      result = described_class.new(nodes, concat: true)
      content = []
      result.append_to(content)
      expect(content.size).to eq(2)
    end

    it "returns content unchanged for none result" do
      result = described_class.none
      content = []
      result.append_to(content)
      expect(content).to eq([])
    end

    it "returns the content array for chaining" do
      node = Metanorma::Mirror::Model::Leaf.new(type: "image")
      result = described_class.new(node)
      content = []
      returned = result.append_to(content)
      expect(returned).to equal(content)
    end

    it "preserves an empty array as a single appended node when concat is false" do
      result = described_class.new([], concat: false)
      content = []
      result.append_to(content)
      expect(content.size).to eq(1)
      expect(content[0]).to eq([])
    end
  end

  describe "#concat?" do
    it "returns false by default" do
      expect(described_class.new(nil).concat?).to be(false)
    end

    it "returns true when set" do
      expect(described_class.new([], concat: true).concat?).to be(true)
    end
  end

  describe "#none?" do
    it "returns true when nodes is nil" do
      expect(described_class.new(nil).none?).to be(true)
    end

    it "returns false when nodes is present" do
      expect(described_class.new([]).none?).to be(false)
    end
  end
end
