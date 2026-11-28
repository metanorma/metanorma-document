# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

# Term definition prose reaching the emitter through <fmt-definition>
# (issue #204): the container declares no mixed/ordered content, so the
# parse captures no element_order — the walk must fall back to the
# declared element mapping instead of silently rendering nothing.
RSpec.describe "term fmt-definition rendering" do
  let(:renderer) { Metanorma::Html::StandardRenderer.new }

  describe "walk_ordered over a container without element_order" do
    let(:fmt_definition) do
      Metanorma::Standoc::Document::Terms::FmtDefinition.from_xml(
        "<fmt-definition id='d1'>" \
        "<semx element='definition' source='_b'><p id='_p'>rice retaining " \
        "its husk after threshing</p></semx>" \
        "</fmt-definition>",
      )
    end

    it "yields the mapped element children in declaration order" do
      events = []
      walked = renderer.walk_ordered(fmt_definition) do |type, obj|
        events << [type, obj.class.name.split("::").last]
      end

      expect(walked).to be(true)
      expect(events).to eq([[:element, "FmtDefinitionSemx"]])
    end

    it "walks the semx slice down to the definition paragraph" do
      semx = fmt_definition.semx.first
      events = []
      renderer.walk_ordered(semx) { |type, obj| events << [type, obj.class] }

      expect(events).to include(
        [:element, Metanorma::Document::Components::Paragraphs::ParagraphBlock],
      )
    end

    it "walks a model without a block (order probe) without yielding" do
      expect(renderer.walk_ordered(fmt_definition)).to be(true)
    end
  end

  describe "full-document emit of the failing shape" do
    let(:xml_path) do
      File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                       __dir__)
    end
    let(:doc) { Metanorma::Iso::Document::Root.from_xml(File.read(xml_path)) }
    let(:html) { Metanorma::Html::Generator.generate(doc) }

    it "renders the definition prose inside the term entry" do
      expect(html).to include("rice retaining its husk after threshing")
    end

    it "keeps the document definition-list count at the native level" do
      # The fixture carries four <dl> elements (clause-embedded
      # definitions); the fix must not mint new definition lists
      # elsewhere.
      expect(html.scan(/<dl[ >]/).size).to eq(4)
    end
  end
end
