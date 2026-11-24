# frozen_string_literal: true

require "spec_helper"

# Slice 1 of metanorma#690 (L5 round-trip): strict XML -> Document model
# -> XML equivalence (element order and text preserved, insignificant
# whitespace normalised) over the semantic fixtures. Complements the
# structural id/count checks in spec/support/shared_roundtrip_examples.rb.
RSpec.describe "Metanorma XML <-> Document model round-trip" do
  fixtures_dir = File.expand_path("../../fixtures", __dir__)

  roots = {
    "iso" => Metanorma::IsoDocument::Root,
    "itu" => Metanorma::ItuDocument::Root,
    "ogc" => Metanorma::OgcDocument::Root,
    "standoc" => Metanorma::Standoc::Document::Root,
  }

  # Known model losses still to be closed in later slices. They stay
  # visible: each is `pending`, so the example fails once it is fixed.
  known_loss_by_name = {
    "iso/is/document-nested-terms.xml" => "1 semantic difference",
    "ogc/19-004/document.xml" => "11 semantic differences (22s run)",
  }

  cases = Dir[File.join(fixtures_dir, "{#{roots.keys.join(',')}}/**/*.xml")]
    .reject { |p| p.end_with?(".presentation.xml") }
    .sort.map do |path|
      name = path.delete_prefix("#{fixtures_dir}/")
      [name, path, roots.fetch(name.split("/").first),
       known_loss_by_name[name]]
    end

  cases.each do |name, path, root_class, known_loss|
    it "round-trips #{name} without loss" do
      pending(known_loss) if known_loss
      xml = File.read(path)

      expect(root_class.from_xml(xml).to_xml).to be_xml_equivalent_to(xml)
    end
  end
end
