# frozen_string_literal: true

require "nokogiri"

# Shared examples for XML round-trip specs.
# Use in spec files via:
#   it_behaves_like "xml round-trip", flavor_dir: "ogc", doc_class: Metanorma::IsoDocument::Root
RSpec.shared_examples "xml round-trip" do |flavor_dir:, doc_class: Metanorma::IsoDocument::Root, full: true|
  fixtures = RoundtripHelper.discover_fixtures(flavor_dir: flavor_dir)

  fixtures.each do |fixture|
    describe fixture[:name] do
      let(:xml) { File.read(fixture[:path]) }
      let(:doc) { doc_class.from_xml(xml) }
      let(:output_xml) { doc.to_xml }
      let(:original_noko) { RoundtripHelper.parse_xml(xml) }
      let(:roundtrip_noko) { RoundtripHelper.parse_xml(output_xml) }

      it "parses without error" do
        doc.should be_a(doc_class)
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

      it "round-trips bibliography normative attributes" do
        RoundtripHelper.bibliography_normative_attrs(roundtrip_noko).should eq(RoundtripHelper.bibliography_normative_attrs(original_noko))
      end

      if full
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
      end

      if fixture[:xml_type] == "presentation"
        it "preserves type=presentation on root" do
          roundtrip_noko.root["type"].should eq("presentation")
        end

        if full
          it "round-trips inline-header attributes" do
            RoundtripHelper.inline_header_count(roundtrip_noko).should eq(RoundtripHelper.inline_header_count(original_noko))
          end
        end
      end
    end
  end
end

RSpec.shared_examples "collection round-trip" do |flavor_dir:|
  require "metanorma/collection"

  collections = RoundtripHelper.discover_collections(flavor_dir: flavor_dir)

  collections.each do |fixture|
    describe fixture[:name] do
      let(:xml) { File.read(fixture[:path]) }
      let(:doc) { Metanorma::Collection::Root.from_xml(xml) }
      let(:output_xml) { doc.to_xml }
      let(:original_noko) { RoundtripHelper.parse_xml(xml) }
      let(:roundtrip_noko) { RoundtripHelper.parse_xml(output_xml) }

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
