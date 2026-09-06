# frozen_string_string: true

require "spec_helper"
require "fileutils"
require "tmpdir"

RSpec.describe Metanorma::Mko::Collection do
  let(:yml_path) do
    File.expand_path("../../fixtures/collection/mini/collection.yml",
                     __dir__)
  end
  let(:out) { Dir.mktmpdir("mko-collection") }

  before do
    # member-2 is generated from member-1 (docid SNR-1 -> SNR-2): the
    # spec owns exactly what it varies, nothing else
    dir = File.dirname(yml_path)
    src = File.read(File.join(dir, "member-1.xml"))
    File.write(File.join(dir, "member-2.xml"),
               src.sub('primary="true">SNR-1<', 'primary="true">SNR-2<'))
  end

  after do
    FileUtils.rm_f(File.join(File.dirname(yml_path), "member-2.xml"))
    FileUtils.remove_entry(out)
  end

  def read_json(bundle, file)
    JSON.parse(File.read(File.join(bundle, file)))
  end

  def read_lines(bundle, file)
    File.readlines(File.join(bundle, file)).map { |l| JSON.parse(l) }
  end

  it "exports every member and the membership bundle" do
    result = described_class.export(yml_path, to: out)
    expect(result.skipped).to be_empty

    # member bundles: the document bundle is the unit of truth
    members = Dir[File.join(out, "*.mko")].select { |p| File.directory?(p) }
    expect(members.size).to eq(3) # two members + the collection

    collection = read_json(result.collection_bundle, "collection.json")
    expect(collection["canonical"]).to eq("SNR Family")
    expect(collection["short"]).to eq("snr-family")
    expect(collection["members"].size).to eq(2)
    docids = collection["members"].map { |m| m["docidentifier"] }
    expect(docids).to contain_exactly("SNR-1", "SNR-2")
    expect(collection["members"].first["bundle"]).to end_with(".mko")

    # cross-document family edges
    edges = read_lines(result.collection_bundle, "edges.jsonl")
    expect(edges).to contain_exactly(
      { "from" => "doc:SNR-1", "to" => "doc:SNR Family", "kind" => "part_of" },
      { "from" => "doc:SNR-2", "to" => "doc:SNR Family", "kind" => "part_of" },
    )

    # manifest-verified like every bundle
    manifest = read_json(result.collection_bundle, "manifest.json")
    expect(manifest["schema"]).to eq("metanorma-mko")
    names = manifest["components"].map { |c| c["name"] }
    expect(names).to include("collection", "edges")
    manifest["components"].each do |c|
      digest = Digest::SHA256.file(File.join(result.collection_bundle, c["file"])).hexdigest
      expect(c["hash"]).to eq("sha256:#{digest}")
    end
  end

  it "records members without compiled XML instead of failing" do
    broken = File.join(out, "broken.yml")
    File.write(broken, <<~YML)
      bibdata:
        docid: { id: "Broken Fam" }
      manifest:
        docref:
          - fileref: missing.adoc
            identifier: X-1
    YML
    result = described_class.export(File.read(broken), to: out)
    expect(result.skipped.size).to eq(1)
    expect(result.skipped.first.identifier).to eq("X-1")
    expect(result.members.select(&:skipped).size).to eq(1)
  end
end
