# frozen_string_literal: true

require_relative "../../spec_helper"

require "metanorma/un_document"

RSpec.describe "UN preface and abstract sections" do
  describe Metanorma::UnDocument::Sections::UnPreface do
    it "maps only the UN grammar preface elements" do
      expect(described_class.attributes.keys).to contain_exactly(
        :abstract, :foreword, :introduction, :semx_id, :displayorder
      )
    end

    it "round-trips abstract, foreword, introduction in grammar order" do
      xml = <<~XML
        <preface>
          <abstract id="_a"><title>Summary</title><p id="_p1">Abstract text</p></abstract>
          <foreword id="_f"><title>Foreword</title><p id="_p2">Foreword text</p></foreword>
          <introduction id="_i"><title>Introduction</title><p id="_p3">Intro</p></introduction>
        </preface>
      XML
      preface = described_class.from_xml(xml)
      rt = Nokogiri::XML(preface.to_xml)
      rt.remove_namespaces!
      children = rt.at_css("preface").children.select(&:element?).map(&:name)
      expect(children).to eq(%w[abstract foreword introduction])
      expect(preface.abstract.id).to eq("_a")
      expect(preface.foreword).to be_a(
        Metanorma::StandardDocument::Sections::ContentSection,
      )
    end

    it "drops acknowledgements forbidden by the UN grammar" do
      xml = <<~XML
        <preface>
          <foreword id="_f"><p>Text</p></foreword>
          <acknowledgements id="_ack"><p>Ack</p></acknowledgements>
        </preface>
      XML
      preface = described_class.from_xml(xml)
      expect(preface.to_xml).not_to include("acknowledgements")
    end
  end

  describe Metanorma::UnDocument::Sections::UnAbstractSection do
    it "parses title and BasicBlock content" do
      xml = <<~XML
        <abstract id="_a">
          <title>Summary</title>
          <p id="_p1">Text</p>
          <ul id="_u"><li><p>item</p></li></ul>
          <note id="_n"><p>note</p></note>
        </abstract>
      XML
      abstract = described_class.from_xml(xml)
      expect(abstract.id).to eq("_a")
      expect(abstract.title).not_to be_nil
      expect(abstract.paragraphs.length).to eq(1)
      expect(abstract.unordered_lists.length).to eq(1)
      expect(abstract.notes.length).to eq(1)
    end

    it "declares no subsection mapping (Basic-Section is a leaf)" do
      expect(described_class.attributes.keys).not_to include(:subsection)
      expect(described_class.mappings_for(:xml).elements.map(&:name)).not_to(
        include("clause"),
      )
    end

    it "drops subsections on round-trip" do
      xml = <<~XML
        <abstract id="_a">
          <p id="_p">Text</p>
          <clause id="_c"><title>Sub</title><p>nested</p></clause>
        </abstract>
      XML
      abstract = described_class.from_xml(xml)
      expect(abstract.to_xml).not_to include("clause")
    end
  end
end
