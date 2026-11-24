# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#296 item 4: sourcecode src= was unmapped at parse
RSpec.describe "src mapping on SourcecodeBlock" do
  it "maps the src attribute" do
    xml = <<~XML
      <sourcecode src="code.rb" anchor="sc1"/>
    XML

    sc = Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock
      .from_xml(xml)

    expect(sc.src).to eq("code.rb")
    expect(sc.anchor).to eq("sc1")
  end
end
