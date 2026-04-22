# frozen_string_literal: true

require_relative "../../../spec_helper"
require "metanorma/collection"

RSpec.describe "OIML Collection XML round-trip" do
  def parse_xml(xml_string)
    RoundtripHelper.parse_xml(xml_string)
  end

  collections = RoundtripHelper.discover_collections(flavor_dir: "oiml/r060")

  collections.each do |fixture|
    describe fixture[:name] do
      let(:xml) { File.read(fixture[:path]) }
      let(:doc) { Metanorma::Collection::Root.from_xml(xml) }
      let(:output_xml) { doc.to_xml }
      let(:original_noko) { parse_xml(xml) }
      let(:roundtrip_noko) { parse_xml(output_xml) }

      it "parses without error" do
        doc.should be_a(Metanorma::Collection::Root)
      end

      it "produces valid XML" do
        RoundtripHelper.xml_has_errors?(output_xml).should be_falsey
      end

      it "round-trips root element name" do
        roundtrip_noko.root.name.should eq("metanorma-collection")
      end

      it "round-trips collection bibdata type" do
        RoundtripHelper.bibdata_type(roundtrip_noko).should eq("collection")
      end

      it "round-trips collection title" do
        orig_title = original_noko.at_css("bibdata > title")&.text&.strip
        rt_title = roundtrip_noko.at_css("bibdata > title")&.text&.strip
        rt_title.should eq(orig_title)
      end

      it "round-trips collection docidentifier" do
        orig_id = original_noko.at_css("bibdata > docidentifier")&.text&.strip
        rt_id = roundtrip_noko.at_css("bibdata > docidentifier")&.text&.strip
        rt_id.should eq(orig_id)
      end

      it "round-trips directive count" do
        RoundtripHelper.collection_directive_count(roundtrip_noko).should eq(
          RoundtripHelper.collection_directive_count(original_noko),
        )
      end

      it "round-trips entry count" do
        RoundtripHelper.collection_entry_count(roundtrip_noko).should eq(
          RoundtripHelper.collection_entry_count(original_noko),
        )
      end

      it "round-trips doc-container count" do
        RoundtripHelper.doc_container_count(roundtrip_noko).should eq(
          RoundtripHelper.doc_container_count(original_noko),
        )
      end

      it "round-trips doc-container IDs" do
        RoundtripHelper.doc_container_ids(roundtrip_noko).should eq(
          RoundtripHelper.doc_container_ids(original_noko),
        )
      end

      it "round-trips embedded document docidentifiers" do
        RoundtripHelper.doc_container_docidentifiers(roundtrip_noko).should eq(
          RoundtripHelper.doc_container_docidentifiers(original_noko),
        )
      end
    end
  end
end
