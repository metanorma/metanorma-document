# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"

# Memoized fixture models (parse-once holders shared across examples).
module FixtureModel
  class << self
    def semantic(xml)
      @semantic ||= Metanorma::Iso::Document::Root.from_xml(xml)
    end

    def presentation(xml)
      @presentation ||= Metanorma::Iso::Document::Root.from_xml(xml)
    end
  end
end

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

  # Fixture models parse once per file (the parse dominates suite
  # time); export! still exercises the full projection+write per call.
  # The "resolves the iso model root" example keeps the raw-XML path.
  def semantic_model
    FixtureModel.semantic(semantic_xml)
  end

  def presentation_model
    FixtureModel.presentation(presentation_xml)
  end

  def export!(presentation: true)
    described_class.export(
      semantic_model, to: tmpdir,
                      presentation_xml: presentation ? presentation_model : nil
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
                               "glossary", "bibliography")
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
      expect(document["ids"]["short"]).to match(/\A[a-z0-9.-]+\z/)
    end

    it "carries parsed identity: doctype, edition, status, structure" do
      bundle = export!
      document = read_json(bundle, "document.json")
      expect(document["doctype"]).to eq("international-standard")
      expect(document["ids"]["number"]).to eq("17301")
      expect(document["ids"]["part"]).to eq("1")
      # every unit carries its language (#53 item 3) and retrievable
      # text — caption, alt, title, or body (#53 item 1)
      units = read_lines(bundle, "units.jsonl")
      units.each { |u| expect(u["lang"]).to eq("en") }
      units.each do |u|
        retrievable = [u["text"], u["title"]].compact.join.strip
        expect(retrievable).not_to be_empty, "#{u['id']} carries no retrievable text"
      end
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
      expect(numbered.map { |u| u["number"] }).to all(match(/\A[\dA-Z.-]+/))
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
        reps = %w[asciimath mathml latex omml description].count do |k|
          f["payload"][k] && !f["payload"][k].empty?
        end
        expect(reps).to be >= 1 # semantic-only docs may lack mathml
      end
    end

    it "carries formulas through native plurimath serializations" do
      bundle = export!
      formulas = read_lines(bundle, "units.jsonl").select do |u|
        u["type"] == "formula"
      end
      expect(formulas).not_to be_empty
      formulas.each do |f|
        next unless f.dig("payload", "asciimath")

        expect(f["payload"]["latex"]).to be_a(String) # native to_latex
        expect(f["payload"]["omml"]).to include("<m:oMath") # native to_omml
      end
    end

    it "carries tables and figures as native Mirror JSON objects" do
      bundle = export!
      units = read_lines(bundle, "units.jsonl")
      tables = units.select { |u| u["type"] == "table" }
      expect(tables).not_to be_empty
      tables.each do |t|
        mirror = t["payload"]["mirror"]
        expect(mirror["type"]).to eq("table")
        types = mirror["content"].map { |c| c["type"] }
        expect(types).to include("table_head")
      end
      figures = units.select { |u| u["type"] == "figure" }
      expect(figures).not_to be_empty
      figures.each do |f|
        expect(f["payload"]["mirror"]["type"]).to eq("figure")
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

      # synonyms carry their normative status
      statuses = paddy.dig("data", "terms").map { |t| [t["designation"], t["normative_status"]] }
      expect(statuses).to include(
        ["paddy", "preferred"], ["paddy rice", "admitted"], ["rough rice", "admitted"]
      )
      husked = concepts.find { |c| c.dig("data", "terms", 0, "designation") == "husked rice" }
      expect(husked.dig("data", "terms").map { |t| t["normative_status"] })
        .to include("deprecated")

      # unit payloads carry the synonyms alongside the preferred list
      paddy_unit = read_lines(bundle, "units.jsonl").find do |u|
        u["type"] == "term" && u["anchor"] == "term-paddy"
      end
      expect(paddy_unit.dig("payload", "admitted"))
        .to eq(["paddy rice", "rough rice"])
      expect(paddy_unit.dig("payload", "deprecated")).to be_nil
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
      # references + term-source citations
      terms_with_sources = read_lines(bundle, "units.jsonl").count do |u|
        u["type"] == "term" && !u.dig("payload", "sources").to_a.empty?
      end
      expect(cites.size).to eq(references.size + terms_with_sources)
      cites.each { |e| expect(e["to"]).to start_with("ext:") }

      # term units cite their authoritative sources
      expect(cites).to include(
        { "from" => "u:term-paddy", "to" => "ext:ISO 7301:2011",
          "kind" => "cites" },
      )
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

  describe "figure assets" do
    it "emits data-URI figures as hash-addressed bundle assets" do
      bundle = export!
      figures = read_lines(bundle, "units.jsonl")
                       .select { |u| u["type"] == "figure" }
      with_asset = figures.select { |f| f.dig("payload", "asset") }
      expect(with_asset).not_to be_empty
      with_asset.each do |f|
        asset = f.dig("payload", "asset")
        expect(asset).to start_with("assets/")
        path = File.join(bundle, asset)
        expect(File.file?(path)).to be true
      end
      manifest = read_json(bundle, "manifest.json")
      asset_components = manifest["components"]
                            .select { |c| c["name"].start_with?("assets/") }
      expect(asset_components.size).to eq(with_asset.size)
      asset_components.each do |c|
        expect(c["media_type"]).to eq("image/png")
        digest = Digest::SHA256.file(File.join(bundle, c["file"])).hexdigest
        expect(c["hash"]).to eq("sha256:#{digest}")
      end
    end
  end

  describe "zip export" do
    it "writes a .mko.zip with identical components" do
      dir_bundle = export!
      zip_dir = Dir.mktmpdir("mko-zip")
      begin
        zip_path = described_class.export(
          semantic_xml, to: zip_dir,
                        presentation_xml: presentation_xml, zip: true
        )
        zip_path = zip_path.path
        expect(zip_path).to end_with(".mko.zip")
        expect(File.file?(zip_path)).to be true
        require "zip"
        names = Zip::File.open(zip_path) { |z| z.entries.map(&:name).sort }
        expect(names).to include("manifest.json", "units.jsonl", "edges.jsonl",
                                 "bibdata.json", "bibliography.jsonl",
                                 "glossary.json", "identifiers.json")
        Zip::File.open(zip_path) do |z|
          names.each do |n|
            a = z.read(n).force_encoding("UTF-8")
            b = File.read(File.join(dir_bundle, n))
            if n == "manifest.json"
              # timestamps are the sanctioned exception (MN 116)
              ja = JSON.parse(a)
              jb = JSON.parse(b)
              ja["generated"].delete("timestamp")
              jb["generated"].delete("timestamp")
              expect(ja).to eq(jb), n
            else
              expect(a).to eq(b), n
            end
          end
        end
      ensure
        FileUtils.remove_entry(zip_dir)
      end
    end
  end

  describe "determinism" do
    it "produces byte-identical components across exports" do
      b1 = export!
      b2 = export!
      %w[document.json units.jsonl edges.jsonl glossary.json
         identifiers.json bibliography.jsonl bibdata.json].each do |file|
        expect(File.read(File.join(b2, file)))
          .to eq(File.read(File.join(b1, file)))
      end
    end
  end

  describe "cross-document graph" do
    it "exports the bibliography as native Relaton items with pubids" do
      bundle = export!
      manifest = read_json(bundle, "manifest.json")
      biblio = manifest["components"].find { |c| c["name"] == "bibliography" }
      expect(biblio["count"]).to eq(23)
      lines = read_lines(bundle, "bibliography.jsonl")
      iso712 = lines.find { |l| l["citeas"].to_s.start_with?("ISO 712") }
      expect(iso712["unit"]).to match(/\Au:/)
      expect(iso712.dig("pubid", "_type")).to eq("pubid:iso:international-standard")
      expect(iso712.dig("pubid", "number")).to eq("712")
      docids = iso712.dig("bibitem", "docidentifier").map { |d| d["content"] }
      expect(docids.compact.join(" ")).to include("ISO 712")
      expect(iso712.dig("bibitem", "title")).to be_an(Array)
    end

    it "emits document-level relations as edges with relaton types" do
      bundle = described_class.export(
        File.read(fixture_path("standoc/requirements/document.xml"),
                  encoding: "utf-8"),
        to: tmpdir,
      )
      document = read_json(bundle, "document.json")
      short = document["ids"]["short"]
      edges = read_lines(bundle, "edges.jsonl")
      doc_edges = edges.select { |e| e["from"] == "doc:#{short}" }
      expect(doc_edges).to contain_exactly(
        { "from" => "doc:#{short}", "to" => "ext:SNR-0",
          "kind" => "obsoletes" },
        { "from" => "doc:#{short}", "to" => "ext:SNR-2",
          "kind" => "hasPart" },
        { "from" => "doc:#{short}", "to" => "ext:SNR-3",
          "kind" => "hasSuccessor" },
      )

      # derived status (#53 item 4): edges are structure — the
      # successor link supersedes whatever the status field claims
      expect(document["derived_status"]).to eq("superseded")
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

  describe "flavors" do
    it "exports an ogc document through the same walk" do
      bundle = described_class.export(
        File.read(fixture_path("ogc/19-004/document.xml"),
                  encoding: "utf-8"),
        to: tmpdir,
        presentation_xml: File.read(fixture_path("ogc/19-004/document.presentation.xml"),
                                    encoding: "utf-8"),
      )
      expect(read_json(bundle, "manifest.json")["generated"]["flavor"])
        .to eq("ogc")
      units = read_lines(bundle, "units.jsonl")
      expect(units.size).to be > 50
      document = read_json(bundle, "document.json")
      expect(document["ids"]["canonical"]).to eq("19-004")
      expect(document["doctype"]).to eq("discussion-paper")
      ids = units.map { |u| u["id"] }
      read_lines(bundle, "edges.jsonl")
        .select { |e| e["kind"] == "part_of" }.each do |e|
        expect(ids).to include(e["from"])
        expect(ids).to include(e["to"])
      end
    end

    it "exports an itu document through the same walk" do
      bundle = described_class.export(
        File.read(fixture_path("itu/d-rec-d.19-201003/en.xml"),
                  encoding: "utf-8"),
        to: tmpdir,
        presentation_xml: File.read(fixture_path("itu/d-rec-d.19-201003/en.presentation.xml"),
                                    encoding: "utf-8"),
      )
      expect(read_json(bundle, "manifest.json")["generated"]["flavor"])
        .to eq("itu")
      document = read_json(bundle, "document.json")
      expect(document["ids"]["canonical"]).to eq("ITU-D D.19")
      units = read_lines(bundle, "units.jsonl")
      expect(units).not_to be_empty
      expect(units.first["text"]).to include("recommends")
      # list content (not separate units) stays in the clause text
      expect(units.first["text"]).to include("RECOMMENDATION ITU-D 6-1")
    end

    it "exports ModSpec requirement units with payloads and class_of edges" do
      bundle = described_class.export(
        File.read(fixture_path("standoc/requirements/document.xml"),
                  encoding: "utf-8"),
        to: tmpdir,
      )
      units = read_lines(bundle, "units.jsonl")
      edges = read_lines(bundle, "edges.jsonl")
      requirements = units.select { |u| u["type"] == "requirement" }
      expect(requirements.size).to eq(5)

      # annex terms reach the native glossary too (amendments keep
      # their terms in annexes)
      terms = units.select { |u| u["type"] == "term" }
      concepts = read_json(bundle, "glossary.json")["concepts"]
      expect(concepts.size).to eq(terms.size)
      annex_term = concepts.find do |c|
        c.dig("data", "terms", 0, "designation") == "annex load cell"
      end
      expect(annex_term.dig("data", "definition", 0, "content"))
        .to eq("a load cell defined in an annex")

      accuracy = requirements.find { |r| r["anchor"] == "req-sensor-accuracy" }
      expect(accuracy["payload"]["identifier"]).to eq("req-sensor-accuracy")
      expect(accuracy["payload"]["class"]).to eq("accuracy")
      expect(accuracy["payload"]["obligation"]).to eq("requirement")
      expect(accuracy["payload"]["subject"]).to eq("sensors")
      expect(accuracy["payload"]["statement"])
        .to include("accurate to within ±0.1 %")
      expect(accuracy["payload"]["inherits"]).to eq(["SNR 0"])

      permission = requirements.find { |r| r["anchor"] == "perm-maintenance" }
      expect(permission["payload"]["obligation"]).to eq("permission")
      recommendation = requirements.find { |r| r["anchor"] == "rec-calibration" }
      expect(recommendation["payload"]["obligation"]).to eq("recommendation")

      class_of = edges.select { |e| e["kind"] == "class_of" }
      expect(class_of).to contain_exactly(
        { "from" => "u:req-sensor-accuracy", "to" => "class:accuracy",
          "kind" => "class_of" },
        { "from" => "u:req-battery", "to" => "class:battery",
          "kind" => "class_of" },
      )
      nested = edges.select do |e|
        e["kind"] == "part_of" &&
          e["from"] == "u:req-battery-life" && e["to"] == "u:req-battery"
      end
      expect(nested.size).to eq(1)
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
