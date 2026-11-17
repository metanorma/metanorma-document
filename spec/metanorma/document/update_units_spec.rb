# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::UpdateUnits do
  let(:components) { Metanorma::Document::Components }
  let(:register_yaml) do
    <<~YAML
      B-400:
        identifier: S-4 Part B, Section 400
        validity:
          begins: 2021-03-01
        records:
          - sequence: 2
            edition: 4.10.0
            date: 2026-03-01
            approval: HSSC-17
            reference: CL 12/2026
            summary:
              - language: en
                content: New B-410 on light sectors
              - language: fr
                content: Nouveau B-410 sur les secteurs de feux
            affected_units: [B-410]
          - sequence: 1
            edition: 4.9.0
            date: 2021-03-01
            approval: HSSC-12
            reference: CL 30/2021
            summary:
              - language: en
                content: Editorial corrections
      B-500:
        - sequence: 1
          edition: 4.9.0
          date: 2021-03-01
          summary:
            - language: en
              content: Initial
      B-600: []
    YAML
  end

  let(:root) do
    components::Sections::HierarchicalSection.new(
      subsections: [section("B-400", [section("B-410")]), section("B-500")],
    )
  end
  let(:register) { described_class.load_register(register_yaml) }

  def section(anchor, children = [])
    components::Sections::HierarchicalSection.new(
      anchor: anchor, subsections: children,
    )
  end

  describe ".load_register" do
    it "reads anchor-keyed records, in either the list or the mapping shape" do
      expect(register.keys).to eq(%w[B-400 B-500 B-600])
      b400 = register["B-400"]
      expect(b400).to be_a(components::UpdateUnits::UpdateUnit)
      expect(b400.unit).to eq("B-400")
      expect(b400.identifier).to eq("S-4 Part B, Section 400")
      expect(b400.validity.begins).to eq(Date.new(2021, 3, 1))
      expect(b400.records.map(&:sequence)).to eq([1, 2])
      expect(register["B-500"].records.first.edition).to eq("4.9.0")
      expect(register["B-600"].records).to eq([])
    end

    it "rejects a register that is not keyed by anchor" do
      expect { described_class.load_register("- a\n- b\n") }
        .to raise_error(ArgumentError, /keyed by unit anchor/)
    end
  end

  describe ".attach and .units" do
    it "attaches records to the divisions they name and reports the rest" do
      unresolved = described_class.attach(root, register)
      expect(unresolved).to eq(%w[B-600])
      expect(described_class.units(root).map { |_, u| u.unit })
        .to eq(%w[B-400 B-500])
    end
  end

  describe ".record_of_updates" do
    it "derives the per-language Record of Updates in amendment order" do
      rows = described_class.record_of_updates(register["B-400"],
                                               language: "fr")
      expect(rows.map(&:sequence)).to eq([1, 2])
      expect(rows.map(&:summary))
        .to eq(["Editorial corrections",
                "Nouveau B-410 sur les secteurs de feux"])
      expect(rows.last.reference).to eq("CL 12/2026")
      expect(rows.last.affected_units).to eq(["B-410"])
    end
  end

  describe ".changed_since" do
    before { described_class.attach(root, register) }

    it "selects units amended after an edition, a date or a sequence" do
      by = ->(point) { described_class.changed_since(root, point).map { |_, u| u.unit } }
      expect(by.call("4.9.0")).to eq(%w[B-400])
      expect(by.call(Date.new(2021, 3, 1))).to eq(%w[B-400])
      expect(by.call(0)).to eq(%w[B-400 B-500])
      expect(by.call("4.10.0")).to eq([])
    end
  end

  describe "the UpdateUnit component" do
    it "derives the last update date from its records" do
      expect(register["B-400"].last_updated_on).to eq(Date.new(2026, 3, 1))
    end

    it "round-trips through XML on a division" do
      div = section("B-400")
      div.update_unit = register["B-400"]
      xml = div.to_xml
      expect(xml).to include('<update-unit unit="B-400">')
      expect(xml).to include('<amendment-record sequence="2">')
      expect(xml).to include('<summary language="fr">')
      again = components::Sections::HierarchicalSection.from_xml(xml)
      unit = again.update_unit
      expect(unit.identifier).to eq("S-4 Part B, Section 400")
      expect(unit.records.map(&:reference)).to eq(["CL 30/2021", "CL 12/2026"])
      expect(unit.records.last.summary_for("en").content)
        .to eq("New B-410 on light sectors")
      expect(unit.records.last.affected_unit).to eq(["B-410"])
    end
  end
end
