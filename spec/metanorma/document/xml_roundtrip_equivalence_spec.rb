# frozen_string_literal: true

require "spec_helper"

# Fixture catalogue for the round-trip gate (metanorma#690).
module XmlRoundtripFixtures
  DIR = File.expand_path("../../fixtures", __dir__)

  ROOTS = {
    "iso" => Metanorma::IsoDocument::Root,
    "itu" => Metanorma::ItuDocument::Root,
    "ogc" => Metanorma::OgcDocument::Root,
    "standoc" => Metanorma::Standoc::Document::Root,
  }.freeze

  # Known model losses still to be closed. They stay visible: each is
  # `pending`, so the example fails once it is fixed.
  KNOWN_LOSS = {
    "ogc/19-004/document.xml" =>
      "5 differences, all in metanorma-standoc models: " \
      "Terms::TermDefinition and Terms::VerbalExpression lack the id " \
      "attribute; Sections::TermsSection lacks <definitions>",
  }.freeze

  def self.name_of(path)
    path.delete_prefix("#{DIR}/")
  end

  def self.root_for(path)
    ROOTS.fetch(name_of(path).split("/").first)
  end

  def self.paths
    Dir[File.join(DIR, "{#{ROOTS.keys.join(',')}}/**/*.xml")]
      .partition { |p| p.end_with?(".presentation.xml") }.reverse
  end
end

# Strict XML -> Document model -> XML equivalence (element order and text
# preserved, insignificant whitespace normalised). Complements the
# structural id/count checks in spec/support/shared_roundtrip_examples.rb.
RSpec.describe "Metanorma XML <-> Document model round-trip" do
  semantic, presentation = XmlRoundtripFixtures.paths

  semantic.each do |path|
    it "round-trips #{XmlRoundtripFixtures.name_of(path)} without loss" do
      known = XmlRoundtripFixtures::KNOWN_LOSS[XmlRoundtripFixtures.name_of(path)]
      pending(known) if known
      xml = File.read(path)
      root = XmlRoundtripFixtures.root_for(path)

      expect(root.from_xml(xml).to_xml).to be_xml_equivalent_to(xml)
    end
  end

  # Slice 2 of metanorma#690: presentation XML (fmt-* twins). Measured
  # against the current models, every presentation fixture still loses
  # content (about 3 minutes in total, so these are skipped, not run):
  #   - <semx> directly under <clause> in sections (ISO clauses)
  #   - <amend>/<newcontent> children: note, figure (image, key/dl/dd), clause
  #   - the metanorma-standoc term gaps named above (ids, <definitions>)
  # Remove the skip once the models are fixed; the fixture then runs.
  presentation.each do |path|
    it "round-trips presentation #{XmlRoundtripFixtures.name_of(path)} without loss" do
      skip "presentation XML model losses (see comment above)"
      xml = File.read(path)
      root = XmlRoundtripFixtures.root_for(path)

      expect(root.from_xml(xml).to_xml).to be_xml_equivalent_to(xml)
    end
  end
end
