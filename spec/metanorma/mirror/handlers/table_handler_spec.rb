# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/iso_document"

RSpec.describe Metanorma::Mirror::Handlers::Table do
  let(:registry) { Metanorma::Mirror.build_default_registry }
  let(:id_strategy) { Metanorma::Mirror::IdStrategy::Preserve.new }
  let(:context) do
    Metanorma::Mirror::Transformer.new(registry: registry,
                                             id_strategy: id_strategy)
  end

  def parse_table(xml)
    Metanorma::Document::Components::Tables::TableBlock.from_xml(xml)
  end

  describe ".call" do
    it "returns a Table hash" do
      el = parse_table("<table id='t1'><tbody><tr><td>Cell</td></tr></tbody></table>")
      result = described_class.call(el, context: context)
      result.type.should eq("table")
    end

    it "extracts thead, tbody, and tfoot" do
      xml = <<~XML
        <table id='t1'>
          <thead><tr><th>H1</th></tr></thead>
          <tbody><tr><td>D1</td></tr></tbody>
          <tfoot><tr><td>F1</td></tr></tfoot>
        </table>
      XML
      el = parse_table(xml)
      result = described_class.call(el, context: context)

      types = result.content.map(&:type)
      types.should eq(%w[table_head table_body table_foot])
    end

    it "extracts table id" do
      el = parse_table("<table id='t1'><tbody><tr><td>X</td></tr></tbody></table>")
      result = described_class.call(el, context: context)
      result.attrs["id"].should eq("t1")
    end

    it "extracts table title from name" do
      el = parse_table("<table id='t1'><name>Table 1</name><tbody><tr><td>X</td></tr></tbody></table>")
      result = described_class.call(el, context: context)
      result.attrs["title"].should eq("Table 1")
    end
  end

  describe ".extract_rows" do
    it "builds TableRow hashes with TableCell children" do
      el = parse_table("<table><tbody><tr><td>A</td><td>B</td></tr></tbody></table>")
      tbody = el.tbody
      rows = described_class.extract_rows(tbody, context: context)
      rows.size.should eq(1)
      rows.first.type.should eq("table_row")
      rows.first.content.size.should eq(2)
      rows.first.content.each { |c| c.type.should eq("table_cell") }
    end
  end

  describe ".build_cell" do
    it "extracts colspan and rowspan" do
      el = parse_table("<table><tbody><tr><td colspan='2' rowspan='3'>X</td></tr></tbody></table>")
      td = el.tbody.tr.first.td.first
      cell = described_class.build_cell(td, context: context)
      cell.attrs["colspan"].should eq(2)
      cell.attrs["rowspan"].should eq(3)
    end
  end
end
