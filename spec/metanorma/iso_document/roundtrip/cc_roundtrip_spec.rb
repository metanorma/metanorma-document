# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "CC document XML round-trip" do
  def parse_xml(xml_string)
    RoundtripHelper.parse_xml(xml_string)
  end

  fixtures = RoundtripHelper.discover_fixtures(flavor_dir: "cc")

  fixtures.each do |fixture|
    describe fixture[:name] do
      let(:xml) { File.read(fixture[:path]) }
      let(:doc) { Metanorma::IsoDocument::Root.from_xml(xml) }
      let(:output_xml) { doc.to_xml }
      let(:original_noko) { parse_xml(xml) }
      let(:roundtrip_noko) { parse_xml(output_xml) }

      it "parses without error" do
        doc.should be_a(Metanorma::IsoDocument::Root)
      end

      it "produces valid XML" do
        RoundtripHelper.xml_has_errors?(output_xml).should be_falsey
      end

      it "round-trips root element and attributes" do
        roundtrip_noko.root.name.should eq("metanorma")
        roundtrip_noko.root["type"].should eq(original_noko.root["type"])
        roundtrip_noko.root["flavor"].should eq(original_noko.root["flavor"])
      end

      it "round-trips bibdata type" do
        RoundtripHelper.bibdata_type(roundtrip_noko).should eq(RoundtripHelper.bibdata_type(original_noko))
      end

      it "round-trips titles" do
        RoundtripHelper.bibdata_titles(roundtrip_noko).should eq(RoundtripHelper.bibdata_titles(original_noko))
      end

      it "round-trips status stage" do
        RoundtripHelper.status_stage(roundtrip_noko).should eq(RoundtripHelper.status_stage(original_noko))
      end

      it "round-trips section clause IDs" do
        RoundtripHelper.section_clause_ids(roundtrip_noko).should eq(RoundtripHelper.section_clause_ids(original_noko))
      end

      it "round-trips preface" do
        RoundtripHelper.has_preface?(roundtrip_noko).should eq(RoundtripHelper.has_preface?(original_noko))
      end

      it "round-trips annex IDs" do
        RoundtripHelper.annex_ids(roundtrip_noko).should eq(RoundtripHelper.annex_ids(original_noko))
      end

      it "round-trips bibliography references sections" do
        RoundtripHelper.bibliography_references_count(roundtrip_noko).should eq(RoundtripHelper.bibliography_references_count(original_noko))
      end

      it "round-trips term IDs" do
        RoundtripHelper.term_ids(roundtrip_noko).should eq(RoundtripHelper.term_ids(original_noko))
      end

      it "round-trips table IDs" do
        RoundtripHelper.table_ids(roundtrip_noko).should eq(RoundtripHelper.table_ids(original_noko))
      end

      it "round-trips figure IDs" do
        RoundtripHelper.figure_ids(roundtrip_noko).should eq(RoundtripHelper.figure_ids(original_noko))
      end

      it "round-trips formula IDs" do
        RoundtripHelper.formula_ids(roundtrip_noko).should eq(RoundtripHelper.formula_ids(original_noko))
      end

      it "round-trips nested clause structure" do
        RoundtripHelper.nested_clause_ids(roundtrip_noko).should eq(RoundtripHelper.nested_clause_ids(original_noko))
      end

      it "round-trips bibliography normative attributes" do
        RoundtripHelper.bibliography_normative_attrs(roundtrip_noko).should eq(RoundtripHelper.bibliography_normative_attrs(original_noko))
      end

      if fixture[:xml_type] == "presentation"
        it "preserves type=presentation on root" do
          roundtrip_noko.root["type"].should eq("presentation")
        end

        it "round-trips inline-header attributes" do
          RoundtripHelper.inline_header_count(roundtrip_noko).should eq(RoundtripHelper.inline_header_count(original_noko))
        end
      end
    end
  end
end
