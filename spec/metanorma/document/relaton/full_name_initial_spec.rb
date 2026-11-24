# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#298 item 4: the singular <initial> spelling was
# unmapped at parse, so person initials arrived only through the
# plural <initials> form
RSpec.describe "singular initial mapping on FullName" do
  it "maps <initial> into initials" do
    xml = <<~XML
      <name><forename>Barney</forename><initial>B. X.</initial><surname>Rubble</surname></name>
    XML

    name = Metanorma::Document::Relaton::FullName.from_xml(xml)

    expect(Array(name.initials).map { |i| Array(i.value).join })
      .to include("B. X.")
  end

  it "parses the singular form to the same shape as <initials>" do
    singular = Metanorma::Document::Relaton::FullName.from_xml(
      "<name><initial>B. X.</initial></name>",
    )
    plural = Metanorma::Document::Relaton::FullName.from_xml(
      "<name><initials>B. X.</initials></name>",
    )

    expect(
      Array(singular.initials).map { |i| Array(i.value).join },
    ).to eq(Array(plural.initials).map { |i| Array(i.value).join })
  end
end
