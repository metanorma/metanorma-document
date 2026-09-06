# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::ModelAccess do
  subject(:walker_class) do
    Class.new do
      include Metanorma::Document::ModelAccess

      attr_reader :root

      def initialize(root)
        @root = root
      end
    end
  end

  let(:xml) do
    File.read(File.expand_path("../../fixtures/iso/is/document-en.xml",
                               __dir__), encoding: "utf-8")
  end
  let(:walker) { walker_class.new(root) }

  def root
    @root ||= Metanorma::Iso::Document::Root.from_xml(xml)
  end

  it "reads declared attributes and nils undeclared ones" do
    expect(walker.val(root, :sections)).to be_a(
      Metanorma::Iso::Document::Sections::IsoSections,
    )
    expect(walker.val(root, :nonexistent)).to be_nil
    expect(walker.val("plain string", :sections)).to be_nil
  end

  it "wraps collections and nils as arrays" do
    expect(walker.vals(root, :nonexistent)).to eq([])
    expect(walker.vals(root.sections, :clause)).to be_an(Array)
  end

  it "recognizes typed model objects" do
    expect(walker.serializable?(root)).to be(true)
    expect(walker.serializable?(Object.new)).to be(false)
  end

  it "resolves document identifiers across tree vocabularies" do
    bib = walker.val(root, :bibdata)
    expect(walker.docids(bib)).not_to be_empty
    expect(walker.docid_text(walker.docids(bib).first)).to be_a(String)
  end
end
