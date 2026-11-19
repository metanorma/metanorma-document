# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::Components::AncillaryBlocks::SourcecodeBody do
  # SourcecodeBody is a type-only model: it declares no element and is
  # embedded through SourcecodeBlock's `map_element "body"`. lutaml-model
  # rejects direct root-level serialization of type-only models with
  # TypeOnlyMappingError, so every spec here drives the class through its
  # real parent — the same path the render layer takes.
  let(:sourcecode_xml) do
    <<~XML
      <sourcecode id="_src" lang="ruby">
        <body>#{body_inner}</body>
      </sourcecode>
    XML
  end

  let(:body_inner) { "&lt;standard&gt; plain" }

  def parse_body
    Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
      .from_xml(sourcecode_xml).body
  end

  describe "#decoded_content" do
    it "decodes XML entities in the markup-encoded content" do
      body = parse_body

      expect(body.decoded_content).to eq("<standard> plain")
    end

    it "decodes numeric character references like named entities" do
      body = Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
        .from_xml(
          "<sourcecode><body>&#x3c;standard&#x3e; plain</body></sourcecode>",
        ).body

      expect(body.decoded_content).to eq("<standard> plain")
    end

    it "keeps the markup-encoded form in content for roundtrip fidelity" do
      body = parse_body

      expect(body.content).to eq("&lt;standard&gt; plain")
    end

    it "keeps XML comments as literal text" do
      body = Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
        .from_xml(
          "<sourcecode><body>&lt;a&gt; <!-- comment --> tail</body>" \
          "</sourcecode>",
        ).body

      expect(body.decoded_content).to include("<!-- comment -->")
    end
  end

  describe "roundtrip" do
    it "round-trips the markup-encoded form without double-escaping" do
      block = Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
        .from_xml(sourcecode_xml)

      xml = block.to_xml

      expect(xml).to include("&lt;standard&gt;")
      expect(xml).not_to include("&amp;lt;")
      expect(xml).to include('id="_src"')
      expect(xml).to include('lang="ruby"')
    end

    it "re-parses its own output to the same decoded content" do
      block = Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
        .from_xml(sourcecode_xml)
      reparsed = Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
        .from_xml(block.to_xml)

      expect(reparsed.body.decoded_content)
        .to eq(parse_body.decoded_content)
    end
  end

  describe "type-only contract" do
    it "rejects direct root-level parsing with TypeOnlyMappingError" do
      expect do
        described_class.from_xml("<body>plain</body>")
      end.to raise_error(Lutaml::Model::TypeOnlyMappingError)
    end

    it "rejects direct root-level serialization with TypeOnlyMappingError" do
      body = parse_body

      expect do
        body.to_xml
      end.to raise_error(Lutaml::Model::TypeOnlyMappingError)
    end
  end
end
