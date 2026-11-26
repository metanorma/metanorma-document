# frozen_string_literal: true

require "spec_helper"
require "isodoc"
require "metanorma-iso"
require "nokogiri"

# Loading metanorma-iso switches the global lutaml-model XML adapter;
# put back the one spec_helper chose, or later specs parse differently.
Lutaml::Model::Config.xml_adapter_type = :nokogiri

RSpec.describe Metanorma::Document::Presentation::Behaviours do
  let(:presentation) { Metanorma::Document::Presentation }
  let(:components) { Metanorma::Document::Components }
  let(:ns) { "http://riboseinc.com/isoxml" }
  let(:layers) do
    presentation::ProfileLoader.from_file(File.expand_path("../../../fixtures/presentation/behaviours.lml", __dir__))
  end

  def profile_for(flavor: nil, taste: nil)
    base = presentation::LayeredProfile.resolve(layers, flavor: flavor, taste: taste)
    described_class.profile(base)
  end

  # Presentation XML from isodoc (base or the ISO flavor) for a clause body.
  def isodoc_presentation(body, flavor: :base)
    xml = <<~XML
      <iso-standard xmlns="#{ns}"><bibdata><language>en</language><script>Latn</script></bibdata>
      <sections><clause id="A" obligation="normative"><title>T</title>#{body}</clause></sections></iso-standard>
    XML
    klass = flavor == :iso ? IsoDoc::Iso::PresentationXMLConvert : IsoDoc::PresentationXMLConvert
    Nokogiri::XML(klass.new({}).convert("t", xml, true))
  end

  def xpath_for(names)
    names.map { |n| ".//#{n.split('/').map { |t| "*[local-name()='#{t}']" }.join('/')}" }.join(" | ")
  end

  # The generated nodes, as comparable text: ids and sources dropped.
  def generated(doc_or_node, names)
    nodes = doc_or_node.xpath(xpath_for(names))
    nodes.map do |n|
      c = n.dup
      c.xpath(".//@id | .//@source | .//@semx-id | .//@original-id").each(&:remove)
      c.remove_attribute("id")
      c.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION)
        .gsub(/\s+xmlns="[^"]*"/, "").gsub(/>\s+</, "><").strip
    end
  end

  # The model for isodoc's own output with the generated nodes taken out,
  # so the engine has to make them again.
  def model_without(node, klass, names)
    copy = node.dup
    copy.xpath(xpath_for(names)).each(&:remove)
    klass.from_xml(copy.to_xml)
  end

  def engine_output(model, profile)
    out = presentation::Engine.new(profile: profile).call(model)
    Nokogiri::XML(out.to_xml(prefix: false)).root
  end

  describe "rule building" do
    it "adds no rule for empty settings" do
      expect(described_class.rules_for({})).to be_empty
    end

    it "rejects a bad value with the property named" do
      expect { described_class.rules_for("footnote_delim_scope" => "some") }
        .to raise_error(presentation::ProfileError, /settings\.footnote_delim_scope.*one of all, body/)
      expect { described_class.rules_for("contributor_name_order" => "x") }
        .to raise_error(presentation::ProfileError, /contributor_name_order/)
    end

    it "layers: a taste overrides a flavor which overrides the base" do
      profile = profile_for(flavor: "iso", taste: "example_dates")
      expect(profile.settings).to include("footnote_close" => ")", "date_format" => "%-d %B %Y")
      expect(profile_for.settings).to eq("date_format" => "own", "footnote_sup" => true,
                                         "contributor_name_order" => "given_family",
                                         "bibdata_current" => true, "address_precompose" => true,
                                         "section_order" => "preface,scope,normref,terms,definitions,middle,annex,bibliography,indexsect,colophon")
    end
  end

  describe "date formats" do
    let(:body) do
      %(<p id="p1">On <date value="2020-01-15" format="%B %-d, %Y"/>, <date value="2021-03" format="%b %Y"/> and <date value="1999-12-31" format="%Y"/>.</p>)
    end
    let(:pres) { isodoc_presentation(body) }
    let(:para) { pres.at_xpath("//xmlns:p[@id='p1']", "xmlns" => ns) }

    it "base profile equals isodoc: each date uses its own format" do
      model = model_without(para, components::Paragraphs::ParagraphBlock, %w[fmt-date])
      out = engine_output(model, profile_for)
      expect(generated(out, %w[fmt-date])).to eq(generated(para, %w[fmt-date]))
      expect(generated(para, %w[fmt-date]).first).to include("January 15, 2020")
    end

    it "a profile format is data only: the taste layer changes every date" do
      model = model_without(para, components::Paragraphs::ParagraphBlock, %w[fmt-date])
      out = engine_output(model, profile_for(taste: "example_dates"))
      expect(generated(out, %w[fmt-date]).map { |x| x[/>([^<]+)</, 1] })
        .to eq(["15 January 2020", "1 March 2021", "31 December 1999"])
    end

    it "keeps the date elements and leaves the input untouched" do
      model = model_without(para, components::Paragraphs::ParagraphBlock, %w[fmt-date])
      presentation::Engine.new(profile: profile_for).call(model)
      expect(model.fmt_date).to be_nil.or be_empty
    end
  end

  describe "footnote markers" do
    let(:body) do
      [%(<p id="p1">Body<fn reference="1"><p id="f1">One</p></fn> text.</p>),
       %(<table id="T1"><tbody><tr><td><p id="c1">Cell<fn reference="a"><p id="f2">Two</p></fn></p></td></tr></tbody></table>)].join
    end

    def expect_parity(flavor_sym, flavor_name)
      pres = isodoc_presentation(body, flavor: flavor_sym)
      container = pres.at_xpath("//xmlns:sections", "xmlns" => ns)
      para = container.at_xpath(".//xmlns:p[@id='p1']", "xmlns" => ns)
      table = container.at_xpath(".//xmlns:table[@id='T1']", "xmlns" => ns)
      [[para, components::Paragraphs::ParagraphBlock], [table, components::Tables::TableBlock]].each do |node, klass|
        model = model_without(node, klass, %w[fn/fmt-fn-label])
        out = engine_output(model, profile_for(flavor: flavor_name))
        expect(generated(out, %w[fn/fmt-fn-label])).to eq(generated(node, %w[fn/fmt-fn-label]))
        expect(generated(node, %w[fn/fmt-fn-label])).not_to be_empty
      end
    end

    it "base profile equals isodoc: superscript reference, no delimiters" do
      expect_parity(:base, nil)
    end

    it "the iso flavor delta (close text outside tables) equals the ISO flavor's output" do
      expect_parity(:iso, "iso")
    end

    it "a hidden reference gets an empty marker" do
      fn = components::Inline::FnElement.from_xml(%(<fn id="x" reference="2" hiddenref="true"><p>N</p></fn>))
      out = presentation::Engine.new(profile: profile_for).call(fn)
      expect(out.fmt_fn_label.to_xml).not_to include("autonum")
    end

    it "flavors differ by profile data only" do
      fn = components::Inline::FnElement.from_xml(%(<fn id="x" reference="2"><p>N</p></fn>))
      texts = { "bsi" => "2)", "bipm" => "(2)", nil => "2" }.to_h do |flavor, _|
        out = presentation::Engine.new(profile: profile_for(flavor: flavor)).call(fn)
        [flavor, Nokogiri::XML(out.fmt_fn_label.to_xml).text.gsub(/\s+/, "")]
      end
      expect(texts).to eq("bsi" => "2)", "bipm" => "(2)", nil => "2")
    end
  end

  describe "contributor name order" do
    let(:people) do
      [%(<root xmlns="#{ns}"><person><name><forename>Anna</forename><forename>B.</forename><surname>Smith</surname></name></person>),
       %(<person><name><formatted-initials>A. B.</formatted-initials><surname>Jones</surname></name></person>),
       %(<person><name><completename>Dr X Y</completename><surname>Z</surname></name></person></root>)].join
    end

    def names(profile)
      persons = Metanorma::Document::Relaton::Person
      Nokogiri::XML(people).xpath("//xmlns:person", "xmlns" => ns).map do |n|
        person = persons.from_xml(n.to_xml)
        out = presentation::Engine.new(profile: profile).call(person)
        Array(out.name.completename&.value).join
      end
    end

    it "base profile equals isodoc's metadata names" do
      meta = IsoDoc::Metadata.new("en", "Latn", nil, IsoDoc::I18n.new("en", "Latn"))
      want = meta.extract_person_names(Nokogiri::XML(people).xpath("//xmlns:person"))
      expect(names(described_class.profile(presentation::Profile.new(settings: { "contributor_name_order" => "given_family" })))).to eq(want)
    end

    it "family-first order is profile data; a given complete name is kept" do
      expect(names(profile_for(taste: "example_dates"))).to eq(["Smith Anna B.", "Jones A. B.", "Dr X Y"])
    end
  end
end
