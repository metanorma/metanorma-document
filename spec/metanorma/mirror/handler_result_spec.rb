# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::HandlerResult do
  describe ".none" do
    it "returns a none-result sentinel" do
      result = described_class.none
      result.none?.should be(true)
      result.nodes.should be_nil
    end

    it "is not Ruby nil itself" do
      described_class.none.nil?.should be(false)
    end
  end

  describe "#append_to" do
    it "appends a single node" do
      node = Metanorma::Mirror::Model::Container.new(type: "paragraph")
      result = described_class.new(node)
      content = []
      result.append_to(content)
      content.size.should eq(1)
      content[0].should eq(node)
    end

    it "concatenates multiple nodes when concat is true" do
      nodes = [
        Metanorma::Mirror::Model::Container.new(type: "paragraph"),
        Metanorma::Mirror::Model::Container.new(type: "note"),
      ]
      result = described_class.new(nodes, concat: true)
      content = []
      result.append_to(content)
      content.size.should eq(2)
    end

    it "returns content unchanged for none result" do
      result = described_class.none
      content = []
      result.append_to(content)
      content.should eq([])
    end

    it "returns the content array for chaining" do
      node = Metanorma::Mirror::Model::Leaf.new(type: "image")
      result = described_class.new(node)
      content = []
      returned = result.append_to(content)
      returned.should equal(content)
    end

    it "preserves an empty array as a single appended node when concat is false" do
      result = described_class.new([], concat: false)
      content = []
      result.append_to(content)
      content.size.should eq(1)
      content[0].should eq([])
    end
  end

  describe "#concat?" do
    it "returns false by default" do
      described_class.new(nil).concat?.should be(false)
    end

    it "returns true when set" do
      described_class.new([], concat: true).concat?.should be(true)
    end
  end

  describe "#none?" do
    it "returns true when nodes is nil" do
      described_class.new(nil).none?.should be(true)
    end

    it "returns false when nodes is present" do
      described_class.new([]).none?.should be(false)
    end
  end
end
