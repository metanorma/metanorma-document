# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::SoftBreak do
  it "returns type as 'soft_break'" do
    sb = described_class.new
    expect(sb.type).to eq("soft_break")
  end

  it "serializes to hash" do
    sb = described_class.new
    expect(sb.to_h).to eq({ "type" => "soft_break" })
  end

  it "has empty attrs and content" do
    sb = described_class.new
    expect(sb.attrs).to eq({})
    expect(sb.content).to eq([])
  end

  describe "#text_content" do
    it "returns empty string" do
      sb = described_class.new
      expect(sb.text_content).to eq("")
    end
  end
end
