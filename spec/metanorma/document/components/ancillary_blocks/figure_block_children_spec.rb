
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

  it "maps singular initial on person names (metanorma-ietf#298 item 4)" do
    xml = <<~XML
      <name><forename>Barney</forename><initial>B. X.</initial><surname>Rubble</surname></name>
    XML

    name = Metanorma::Document::Relaton::FullName.from_xml(xml)

    expect(Array(name.initials).map(&:value)).to include("B. X.")
  end
end
