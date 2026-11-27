# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe "fmt-name caption text extraction" do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:doc) { Metanorma::Iso::Document::Root.from_xml(File.read(xml_path)) }
  let(:renderer) { Metanorma::Html::BaseRenderer.allocate }

  def find_with_fmt_name(node, seen = {}.compare_by_identity)
    return nil if seen[node]

    seen[node] = true
    return node if node.class.respond_to?(:attributes) &&
      node.class.attributes.key?(:fmt_name) &&
      Array(node.fmt_name).first

    return nil unless node.class.respond_to?(:attributes)

    node.class.attributes.each_key do |k|
      Array(node.public_send(k)).each do |child|
        found = find_with_fmt_name(child, seen)
        return found if found
      end
    end
    nil
  end

  it "returns plain caption text without markup" do
    block = find_with_fmt_name(doc)
    expect(block).not_to be_nil
    text = renderer.fmt_name_text(block)
    expect(text).to be_a(String)
    expect(text).not_to match(/[<>]/)
    expect(text).not_to match(/\s{2}| /)
  end

  it "returns nil when fmt_name is absent" do
    obj = Struct.new(:fmt_name).new(nil)
    allow(renderer).to receive(:safe_attr) { |o, n| o.public_send(n) }
    expect(renderer.fmt_name_text(obj)).to be_nil
  end

  it "no longer strips tags with regular expressions" do
    src = File.read(File.expand_path("../../../../lib/metanorma/html/base_renderer.rb", __dir__))
    expect(src).not_to include("gsub(/<[^>]")
  end
end
