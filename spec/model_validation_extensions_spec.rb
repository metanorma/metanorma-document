# frozen_string_literal: true

require "spec_helper"

RSpec.describe "metanorma-document model extensions for validation", type: :model do
  describe "SubElement recursive nesting" do
    it "preserves nested sub elements" do
      xml = "<sub>x<sub>y</sub></sub>"
      sub = Metanorma::Document::Components::Inline::SubElement.from_xml(xml)
      expect(sub.sub.size).to eq(1)
      expect(sub.sub.first.content).to eq("y")
    end
  end
end
