# frozen_string_literal: true

require "spec_helper"
require "json"
require "tmpdir"

RSpec.describe Metanorma::Mko::Schema::JsonSchema do
  let(:schemas) { described_class.all }
  let(:xml) do
    File.read(File.expand_path("../../fixtures/iso/is/document-en.xml",
                               __dir__), encoding: "utf-8")
  end

  def mismatch(schema_props, value, path)
    value.each do |key, v|
      prop = schema_props[key]
      return "#{path}.#{key}: not in schema (schema drift)" unless prop

      expected = prop["type"]
      if expected == "array" && !v.is_a?(Array)
        return "#{path}.#{key}: expected array"
      elsif expected == "string" && !v.is_a?(String)
        return "#{path}.#{key}: expected string"
      elsif expected == "object" && !v.is_a?(Hash)
        return "#{path}.#{key}: expected object"
      end
    end
    nil
  end

  it "covers every typed payload a real bundle ships, with wire names" do
    dir = Dir.mktmpdir("schema-drift")
    begin
      bundle = Metanorma::Mko.export(xml, to: dir)
      units = File.readlines(File.join(bundle, "units.jsonl"))
        .map { |l| JSON.parse(l) }
      payloads = units.group_by { |u| u["type"] }
      payloads.each do |type, typed|
        typed.reject { |u| u["payload"].nil? }.each do |u|
          schema = schemas["payload-#{type}"]
          expect(schema).to be_a(Hash), "no schema for payload #{type}"
          err = mismatch(schema["properties"], u["payload"], "payload-#{type}")
          expect(err).to be_nil, err.to_s
        end
      end
    ensure
      FileUtils.remove_entry(dir)
    end
  end

  it "uses the json mappings' wire names, not Ruby handles" do
    expect(schemas["payload-requirement"]["properties"]).to include("class")
    expect(schemas["payload-requirement"]["properties"])
      .not_to include("klass")
  end

  it "carries the latest payload fields (the regression guard)" do
    expect(schemas["payload-term"]["properties"]).to include(
      "admitted", "deprecated"
    )
    expect(schemas["payload-formula"]["properties"]).to include(
      "latex", "omml"
    )
    %w[mirror].each do |field|
      expect(schemas["payload-table"]["properties"]).to include(field)
      expect(schemas["payload-figure"]["properties"]).to include(field)
    end
  end

  it "defines the consumer excerpt with unit_id, type, payload" do
    block = schemas["excerpt"]["properties"]["blocks"]["items"]
    expect(block["required"]).to eq(%w[unit_id type payload])
    expect(block["properties"]["unit_id"]["pattern"]).to eq("\\Au:")
  end
end
