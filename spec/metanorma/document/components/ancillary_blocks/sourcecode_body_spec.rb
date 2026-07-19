# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::Components::AncillaryBlocks::SourcecodeBody do
  describe "#decoded_content" do
    it "decodes XML entities in the markup-encoded content" do
      body = described_class.from_xml(
        "<body>&#x3c;standard&#x3e; &lt;escaped&gt; plain</body>",
      )
      expect(body.decoded_content).to eq("<standard> <escaped> plain")
    end

    it "keeps the markup-encoded form in content for roundtrip fidelity" do
      body = described_class.from_xml(
        "<body>&#x3c;standard&#x3e; &lt;escaped&gt; plain</body>",
      )
      expect(body.content).to eq("&lt;standard&gt; &lt;escaped&gt; plain")
    end

    it "keeps XML comments as literal text" do
      body = described_class.from_xml(
        "<body>&#x3c;a&#x3e; <!-- comment --> tail</body>",
      )
      expect(body.decoded_content).to include("<!-- comment -->")
    end

    it "round-trips the markup-encoded form without double-escaping" do
      body = described_class.from_xml("<body>&#x3c;standard&#x3e;</body>")
      expect(body.to_xml).not_to include("&amp;lt;")
    end
  end
end
