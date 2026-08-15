# frozen_string_literal: true

require_relative "../../../../spec_helper"

RSpec.describe Metanorma::Document::Components::Blocks::RequirementModel do
  it "maps identifier, title and the presentation rendering channels" do
    xml = <<~XML
      <requirement id="_r1" model="default" obligation="requirement">
        <fmt-name><span class="fmt-caption-label">Requirement 1</span></fmt-name>
        <fmt-xref-label><span class="fmt-element-name">Requirement</span></fmt-xref-label>
        <title>Accuracy of measurement</title>
        <identifier>NO-ACC</identifier>
        <subject>measuring system</subject>
        <description><p>The system shall measure accurately.</p></description>
        <specification><p>Specification content</p></specification>
        <measurement-target><p>Measurement target content</p></measurement-target>
        <verification><p>Verification content</p></verification>
        <import><p>Imported requirement content</p></import>
        <fmt-provision><p>Rendered provision body</p></fmt-provision>
      </requirement>
    XML

    req = described_class.from_xml(xml)

    expect(req.identifier).to eq("NO-ACC")
    expect(req.title.value).to eq(["Accuracy of measurement"])
    expect(req.fmt_name).to be_a(Metanorma::Document::Components::Inline::FmtNameElement)
    expect(req.fmt_xref_label).to all(be_a(Metanorma::Document::Components::Inline::FmtXrefLabelElement))
    expect(req.specification.first.p.first.text).to eq(["Specification content"])
    expect(req.measurement_target.first.p.first.text).to eq(["Measurement target content"])
    expect(req.verification.first.p.first.text).to eq(["Verification content"])
    expect(req.import.first.p.first.text).to eq(["Imported requirement content"])
    expect(req.fmt_provision.p.first.text).to eq(["Rendered provision body"])
  end

  it "keeps the mapping on the recommendation carrier" do
    xml = <<~XML
      <recommendation id="_rec1" model="default">
        <identifier>REC-1</identifier>
        <title>Follow the process</title>
        <description><p>Do the thing.</p></description>
        <fmt-provision><p>Rendered recommendation</p></fmt-provision>
      </recommendation>
    XML

    rec = Metanorma::Document::Components::Blocks::RecommendationModel.from_xml(xml)

    expect(rec.identifier).to eq("REC-1")
    expect(rec.title.value).to eq(["Follow the process"])
    expect(rec.fmt_provision.p.first.text).to eq(["Rendered recommendation"])
  end

  it "keeps the mapping on the permission carrier" do
    xml = <<~XML
      <permission id="_perm1" model="default">
        <identifier>PERM-1</identifier>
        <title>Allow the action</title>
        <description><p>The action is allowed.</p></description>
        <fmt-provision><p>Rendered permission</p></fmt-provision>
      </permission>
    XML

    perm = Metanorma::Document::Components::Blocks::PermissionModel.from_xml(xml)

    expect(perm.identifier).to eq("PERM-1")
    expect(perm.title.value).to eq(["Allow the action"])
    expect(perm.fmt_provision.p.first.text).to eq(["Rendered permission"])
  end
end
