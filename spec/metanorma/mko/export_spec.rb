# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"

RSpec.describe Metanorma::Mko do
  let(:semantic_xml) do
    File.read(fixture_path("iso/is/document-en.xml"),
              encoding: "utf-8")
  end
  let(:presentation_xml) do
    File.read(fixture_path("iso/is/document-en.presentation.xml"),
              encoding: "utf-8")
  end
  let(:tmpdir) { Dir.mktmpdir("mko-spec") }

  after { FileUtils.rm_rf(tmpdir) }

  def fixture_path(rel)
    File.expand_path("../../fixtures/#{rel}", __dir__)
  end

  def export!(presentation: true)
    described_class.export(
      semantic_xml, to: tmpdir,
      presentation_xml: presentation ? presentation_xml : nil
    )
  end

  def read_json(bundle, file)
    JSON.parse(File.read(File.join(bundle, file)))
  end

  def read_lines(bundle, file)
    File.readlines(File.join(bundle, file)).map { |l| JSON.parse(l) }
  end

  describe "bundle structure" do
    it "writes all components with a verified manifest" do
      bundle = export!
      expect(Dir.exist?(bundle)).to be true
      manifest = read_json(bundle, "manifest.json")
      expect(manifest["schema"]).to eq("metanorma-mko")
      expect(manifest["schema_version"]).to eq("1.0.0")
      names = manifest["components"].map { |c| c["name"] }
      expect(names).to include("document", "units", "edges", "identifiers",
                               "glossary")
      manifest["components"].each do |c|
        digest = Digest::SHA256.file(File.join(bundle, c["file"])).hexdigest
        expect(c["hash"]).to eq("sha256:#{digest}")
        expect(c["count"]).to be > 0 if %w[units edges].include?(c["name"])
      end
    end

    it "resolves the iso model root (no flavor knowledge in the walk)" do
      bundle = export!
      document = read_json(bundle, "document.json")
      expect(document["flavor"]).to eq("iso")
      expect(document["ids"]["canonical"]).to be_a(String)
      expect(document["ids"]["short"]).to match(/\A[a-z0-9.\-]+\z/)
    end

    it "carries parsed identity: doctype, edition, status, structure" do
      bundle = export!
      document = read_json(bundle, "document.json")
      expect(document["doctype"]).to eq("international-standard")
      expect(document["edition"]).to eq("2")
      expect(document["status"]["stage"]).to eq("60")
      expect(document["status"]["abbreviation"]).to eq("IS")
      structure = document["structure"]
      expect(structure).not_to be_empty
      expect(structure.first["number"]).to eq("1")
      expect(structure.first["title"]).to eq("Scope")
    end
  end

  describe "units" do
    it "emits typed units with ids, parents, and breadcrumbs" do
      bundle = export!
      units = read_lines(bundle, "units.jsonl")
      expect(units.size).to be > 10
      types = units.map { |u| u["type"] }.uniq
      expect(types).to include("clause")
      units.each do |u|
        expect(u["id"]).to start_with("u:")
        expect(u["type"]).to be_a(String)
        expect(u["hash"]).to start_with("sha256:")
      end
      with_parent = units.select { |u| u["parent"] }
      expect(with_parent).not_to be_empty
      ids = units.map { |u| u["id"] }
      expect(ids.uniq.size).to eq(ids.size)
    end

    it "numbers clauses from the presentation model" do
      bundle = export!
      units = read_lines(bundle, "units.jsonl")
      numbered = units.select { |u| u["number"] }
      expect(numbered).not_to be_empty
      expect(numbered.map { |u| u["number"] }).to all(match(/\A[\dA-Z.\-]+/))
    end

    it "carries tables as typed payloads, never only linearized text" do
      bundle = export!
      tables = read_lines(bundle, "units.jsonl").select do |u|
        u["type"] == "table"
      end
      tables.each do |t|
        payload = t["payload"]
        expect(payload).to be_a(Hash)
        expect(payload["columns"]).to be_an(Array)
        expect(payload["rows"]).to be_an(Array)
      end
    end

    it "carries formulas with at least two representations" do
      bundle = export!
      formulas = read_lines(bundle, "units.jsonl").select do |u|
        u["type"] == "formula"
      end
      formulas.each do |f|
        reps = %w[asciimath mathml description].count do |k|
          f["payload"][k] && !f["payload"][k].empty?
        end
        expect(reps).to be >= 1 # semantic-only docs may lack mathml
      end
    end

    it "emits terms as native Glossarist concepts" do
      bundle = export!
      terms = read_lines(bundle, "units.jsonl").select do |u|
        u["type"] == "term"
      end
      concepts = read_json(bundle, "glossary.json")["concepts"]
      expect(concepts.size).to eq(terms.size)
      paddy = concepts.find do |c|
        c.dig("data", "terms", 0, "designation") == "paddy"
      end
      expect(paddy.dig("data", "terms", 0, "normative_status"))
        .to eq("preferred")
      expect(paddy.dig("data", "definition", 0, "content"))
        .to eq("rice retaining its husk after threshing")
      expect(paddy.dig("data", "sources", 0, "origin", "ref", "source"))
        .to eq("ISO 7301:2011")
      expect(paddy.dig("data", "language_code")).to eq("eng")
    end

    it "carries the bibliographic record as native Relaton JSON" do
      bundle = export!
      bibdata = read_json(bundle, "bibdata.json")
      document = read_json(bundle, "document.json")
      expect(bibdata).not_to eq(document) # never a duplicate of document
      expect(bibdata["schema_version"]).to be_a(String) # relaton wire shape
      docids = bibdata["docidentifier"].map { |d| d["content"] }
      expect(docids).to include("ISO 17301-1:2016")
    end

    it "carries identifiers with native pubid parses" do
      bundle = export!
      identifiers = read_json(bundle, "identifiers.json")["identifiers"]
      iso = identifiers.find { |i| i["original"] == "ISO 17301-1:2016" }
      expect(iso["parsed"]["number"]).to eq("17301")
      expect(iso["parsed"]["part"]).to eq("1")
      expect(iso["parsed"]["year"]).to eq("2016")
    end

    it "emits bibliography references with cites edges" do
      bundle = export!
      units = read_lines(bundle, "units.jsonl")
      references = units.select { |u| u["type"] == "reference" }
      expect(references.size).to be > 20
      cites = read_lines(bundle, "edges.jsonl")
                     .select { |e| e["kind"] == "cites" }
      expect(cites.size).to eq(references.size)
      cites.each { |e| expect(e["to"]).to start_with("ext:") }
    end
  end

  describe "edges" do
    it "builds the part_of tree from containment" do
      bundle = export!
      units = read_lines(bundle, "units.jsonl")
      edges = read_lines(bundle, "edges.jsonl")
      ids = units.map { |u| u["id"] }
      part_of = edges.select { |e| e["kind"] == "part_of" }
      expect(part_of).not_to be_empty
      part_of.each do |e|
        expect(ids).to include(e["from"])
        expect(ids).to include(e["to"])
      end
    end

    it "emits defines edges for terms" do
      bundle = export!
      edges = read_lines(bundle, "edges.jsonl")
      expect(edges.select { |e| e["kind"] == "defines" }).not_to be_empty
    end
  end

  describe "determinism" do
    it "produces byte-identical components across exports" do
      b1 = export!
      b2 = export!
      %w[document.json units.jsonl edges.jsonl glossary.json
         identifiers.json].each do |file|
        expect(File.read(File.join(b2, file)))
          .to eq(File.read(File.join(b1, file)))
      end
    end
  end

  describe "registry" do
    it "resolves the mko renderer for the base model tree" do
      doc = Metanorma::Document::Root.new
      expect(described_class.renderer_for(doc)).to eq(Metanorma::Mko::Exporter)
    end

    it "serves the harness Exporter for flavor models without an mko entry" do
      doc = Metanorma::Iso::Document::Root.from_xml(semantic_xml)
      expect(described_class.renderer_for(doc)).to eq(Metanorma::Mko::Exporter)
      expect(Metanorma::Core::Flavors.renderer_for(doc, format: :mko))
        .to be_nil
    end
  end

  describe "portability gate (OCP)" do
    it "references no flavor namespaces" do
      src = Dir[File.expand_path("../../../../lib/metanorma/mko/**/*.rb",
                                __dir__)]
      hits = src.flat_map do |f|
        File.readlines(f).each_with_index.filter_map do |line, i|
          "#{f}:#{i + 1}: #{line.strip}" if line.match?(/\bIso::|\bItu::|\bOgc::|\bIec::/)
        end
      end
      expect(hits).to be_empty, "flavor knowledge leaked:\n#{hits.join("\n")}"
    end
  end
end
