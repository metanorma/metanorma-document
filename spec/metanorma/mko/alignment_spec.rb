# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"

RSpec.describe Metanorma::Mko::Alignment do
  let(:xml) do
    File.read(fixture_path("standoc/requirements/document.xml"),
              encoding: "utf-8")
  end
  let(:dir) { Dir.mktmpdir("align") }

  def fixture_path(rel)
    File.expand_path("../../fixtures/#{rel}", __dir__)
  end

  after { FileUtils.remove_entry(dir) }

  it "aligns same-anchored units across editions with variant_of" do
    a = Metanorma::Mko.export(xml, to: dir)
    b = Metanorma::Mko.export(xml, to: dir)
    edges = described_class.align(a, b)
    expect(edges).not_to be_empty
    edges.each do |e|
      expect(e.kind).to eq("variant_of")
      expect(e.from).to start_with("u:")
      expect(e.from).to eq(e.to) # same doc: anchors pair with themselves
    end
    # anchored semantic units participate; hash-fallback anchors do not
    expect(edges.map(&:from)).to include("u:req-sensor-accuracy")
    expect(edges.map(&:from)).not_to include(match(/\Ah-/))

    path = described_class.export(a, b)
    lines = File.readlines(path).map { |l| JSON.parse(l) }
    expect(lines.size).to eq(edges.size)
    expect(lines.first["kind"]).to eq("variant_of")
  end
end
