# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#292: <name> carries inline markup (xref, em, ...)
# in the metanorma vocabulary; NameWithIdElement mapped only the text
# runs, so caption/name content vanished at parse
RSpec.describe "inline vocabulary on NameWithIdElement" do
  it "maps inline children in source order" do
    xml = <<~XML
      <name>see <em>this</em> <xref target="other"/></name>
    XML

    name = Metanorma::Document::Components::Inline::NameWithIdElement
      .from_xml(xml)

    order = name.element_order.map do |e|
      e.text? ? :text : e.element_tag
    end
    expect(order).to eq([:text, "em", :text, "xref"])
    expect(name.xref.first.target).to eq("other")
  end

  it "keeps plain names working" do
    xml = '<name>Figure 1</name>'

    name = Metanorma::Document::Components::Inline::NameWithIdElement
      .from_xml(xml)

    expect(Array(name.text).join).to eq("Figure 1")
  end
end
