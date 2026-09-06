# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"
require "json"

RSpec.describe Metanorma::Mko::Mcp::Server do
  let(:xml) do
    File.read(File.expand_path("../../fixtures/standoc/requirements/document.xml",
                               __dir__), encoding: "utf-8")
  end
  let(:dir) { Dir.mktmpdir("mko-mcp") }
  let(:bundle) do
    Metanorma::Mko.export(xml, to: dir).path
  end
  let(:server) { described_class.new(bundle) }

  def rpc(id, method, params = nil)
    line = { "jsonrpc" => "2.0", "id" => id, "method" => method }
    line["params"] = params if params
    JSON.parse(server.handle(JSON.generate(line)))
  end

  after { FileUtils.remove_entry(dir) }

  it "initializes and lists the contract tools" do
    init = rpc(1, "initialize")
    expect(init["result"]["serverInfo"]["name"]).to eq("metanorma-mko")
    names = rpc(2, "tools/list")["result"]["tools"].map { |t| t["name"] }
    expect(names).to contain_exactly(
      "search_units", "get_unit", "walk_edges", "edition_diff"
    )
  end

  it "searches units, returns payloads, and walks edges" do
    found = rpc(3, "tools/call",
                { "name" => "search_units",
                  "arguments" => { "query" => "sensor accuracy requirement" } })
    hits = JSON.parse(found["result"]["content"][0]["text"])
    expect(hits).not_to be_empty
    top = hits.first
    expect(top["id"]).to start_with("u:")

    unit = rpc(4, "tools/call",
               { "name" => "get_unit", "arguments" => { "id" => top["id"] } })
    body = JSON.parse(unit["result"]["content"][0]["text"])
    expect(body["type"]).to eq(top["type"])
    expect(body).to include("text")

    edges = rpc(5, "tools/call",
                { "name" => "walk_edges",
                  "arguments" => { "unit_id" => top["id"] } })
    list = JSON.parse(edges["result"]["content"][0]["text"])
    expect(list).not_to be_empty
    expect(list.first).to include("kind")
  end

  it "answers edition diffs" do
    edition_b = xml.sub("±0.1 %", "±0.05 %")
    b = Metanorma::Mko.export(edition_b, to: File.join(dir, "b")).path
    res = rpc(6, "tools/call",
              { "name" => "edition_diff",
                "arguments" => { "bundle_a" => bundle, "bundle_b" => b } })
    diff = JSON.parse(res["result"]["content"][0]["text"])
    expect(diff["changed"].map { |c| c["anchor"] })
      .to include("req-sensor-accuracy")
  end

  it "errors cleanly on unknown tools and methods" do
    err = rpc(7, "tools/call", { "name" => "nope", "arguments" => {} })
    expect(err["error"]["code"]).to eq(-32_603)
    missing = rpc(8, "resources/list")
    expect(missing["error"]["code"]).to eq(-32_601)
  end
end
