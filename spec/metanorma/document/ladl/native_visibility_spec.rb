# frozen_string_literal: true

require "rspec"
require "nokogiri"
require_relative "../../../../lib/metanorma/document"
require "metanorma/standoc/document"
require "metanorma/iso/document"

RSpec.describe "Native presentation visibility fidelity" do
  before { Lutaml::Model::Config.xml_adapter_type = :nokogiri }

  kinds = %w[clause figure subfigure table note]
  states = [true, false, nil]
  [Metanorma::Standoc::Document::Root, Metanorma::Iso::Document::Root].each do |root_class|
    kinds.each do |kind|
      states.each do |hidden|
        it "retains #{kind} hidden=#{hidden.inspect} on #{root_class}" do
          attribute = hidden.nil? ? "" : %( hidden="#{hidden}")
          label = '<fmt-xref-label>before<semx element="autonum" source="authored">A</semx>' \
                  '<span class="delimiter">.</span>after<fmt-ladl-label-data local="authored" value="A" labeller="existing"/></fmt-xref-label>'
          element = %(<#{kind == 'subfigure' ? 'figure' : kind} id="target"#{attribute}>#{label}</#{kind == 'subfigure' ? 'figure' : kind}>)
          element = "<figure>#{element}</figure>" if kind == "subfigure"
          element = "<clause>#{element}</clause>" unless kind == "clause"
          xml = %(<metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation"><sections>#{element}</sections></metanorma>)
          root = root_class.from_xml(xml)
          clause = root.sections.clause.first
          target = case kind
                   when "clause" then clause
                   when "figure" then clause.figures.first
                   when "subfigure" then clause.figures.first.figure.first
                   when "table" then clause.tables.first
                   when "note" then clause.notes.first
                   end
          expect(target.class.attributes.fetch(:hidden).type).to eq(Lutaml::Model::Type::Boolean)
          expect(target.hidden).to eq(hidden)
          authored = target.fmt_xref_label.first
          original = authored.to_xml
          serialized = root.to_xml
          expect(Nokogiri::XML(serialized).at_xpath('//*[@id="target"]')["hidden"])
            .to eq(hidden&.to_s)
          expect(authored.to_xml).to eq(original)
          reparsed = root_class.from_xml(serialized)
          expect(Nokogiri::XML(reparsed.to_xml).at_xpath('//*[@id="target"]')["hidden"])
            .to eq(hidden&.to_s)
          expect(target.fmt_xref_label.first).to equal(authored)
          expect(authored.fmt_ladl_label_data.local).to eq("authored")
        end
      end
    end
  end
end
