# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Model::SoftBreak do
  it "returns type as 'soft_break'" do
    sb = described_class.new
    sb.type.should eq("soft_break")
  end

  it "serializes to hash" do
    sb = described_class.new
    sb.to_h.should eq({ "type" => "soft_break" })
  end

  it "has empty attrs and content" do
    sb = described_class.new
    sb.attrs.should eq({})
    sb.content.should eq([])
  end

  describe "#text_content" do
    it "returns empty string" do
      sb = described_class.new
      sb.text_content.should eq("")
    end
  end
end
