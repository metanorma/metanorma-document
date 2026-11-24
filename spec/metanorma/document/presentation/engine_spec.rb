# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"
require "metanorma/standoc"

RSpec.describe Metanorma::Document::Presentation::Engine do
  let(:fixtures) { File.expand_path("../../../fixtures", __dir__) }
  let(:samples) do
    %w[iso/is/document-en.presentation.xml
       iso/amd/document-en.final.presentation.xml
       ogc/19-004/document.presentation.xml]
  end
  let(:root) { Metanorma::Standoc::Document::Root }

  before { Lutaml::Model::Config.xml_adapter_type = :nokogiri }

  it "yields an identical model for the no-op profile on corpus samples" do
    samples.each do |sample|
      doc = root.from_xml(File.read(File.join(fixtures, sample)))
      before_xml = doc.to_xml
      result = described_class.new(profile: Metanorma::Document::Presentation::Profile.noop).call(doc)
      expect(result).to be_a(root)
      expect(result).not_to equal(doc)
      expect(result.to_xml).to eq(before_xml), sample
      expect(doc.to_xml).to eq(before_xml), "input mutated: #{sample}"
    end
  end

  it "defaults to the no-op profile" do
    expect(described_class.new.profile).to be_noop
  end

  it "applies rules in order to the copy only" do
    doc = root.from_xml(File.read(File.join(fixtures, samples.first)))
    seen = []
    profile = Metanorma::Document::Presentation::Profile.new(
      name: "probe", rules: [->(m) { seen << [1, m] }, ->(m) { seen << [2, m] }],
    )
    result = described_class.new(profile: profile).call(doc)
    expect(seen.map(&:first)).to eq([1, 2])
    expect(seen.map(&:last)).to all(equal(result))
  end

  it "has no isodoc dependency in its sources" do
    dir = File.expand_path("../../../../lib/metanorma/document", __dir__)
    files = Dir[File.join(dir, "presentation.rb"), File.join(dir, "presentation/*.rb")]
    expect(files).not_to be_empty
    files.each { |f| expect(File.read(f)).not_to match(/isodoc/i), f }
  end
end
