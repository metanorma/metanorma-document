# frozen_string_literal: true

require "spec_helper"

# The facade's profile-parameter surface: publisher configuration
# (DTD version, processing-meta element, post-processing) flows into
# the conversion without any engine edits. Real models throughout —
# the profiles below differ in plain configuration only.
RSpec.describe "Metanorma::Document::Sts facade with profiles" do
  let(:reader) { Metanorma::Iso::Document::Root }

  let(:input_xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation" flavor="iso">
        <bibdata type="standard">
          <title language="en" type="main">Facade spec doc</title>
          <docidentifier primary="true" type="ISO">ISO 3</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1" type="scope"><title>Scope</title><p id="p1">Scope text.</p></clause>
        </sections>
      </metanorma>
    XML
  end

  def register(name, **opts)
    Metanorma::Document::Sts::Profiles.register(
      Metanorma::Document::Sts::Profile.new(
        name: name, dtd_version: "1.0", reader_class: reader, **opts,
      ),
    )
    name
  end

  describe ".convert" do
    it "carries the profile's dtd-version" do
      legacy = register(:"wave0_facade_legacy_#{object_id}", dtd_version: "1.2")
      modern = register(:"wave0_facade_modern_#{object_id}", dtd_version: "1.0")

      legacy_xml = Metanorma::Document::Sts.convert(input_xml, profile: legacy)
      modern_xml = Metanorma::Document::Sts.convert(input_xml, profile: modern)

      expect(legacy_xml).to include('dtd-version="1.2"')
      expect(modern_xml).to include('dtd-version="1.0"')
      expect(legacy_xml).to include("<std-meta>")
      expect(modern_xml).to include("<std-meta>")
    ensure
      Metanorma::Document::Sts::Profiles.delete(legacy)
      Metanorma::Document::Sts::Profiles.delete(modern)
    end

    it "injects the profile's processing-meta element and runs the profile's post-processors" do
      oiml_style = register(
        :"wave0_facade_oiml_#{object_id}",
        processing_meta: '<processing-meta tagset-family="sts" ' \
                         'base-tagset="interchange" table-model="xhtml" ' \
                         'mathml="MathML 3.0" terminology-model="tbx"/>',
      )
      iso_style = register(
        :"wave0_facade_iso_#{object_id}",
        processing_meta: '<processing-meta tagset-family="sts" ' \
                         'base-tagset="interchange" table-model="xhtml" ' \
                         'mathml-version="3.0" math-representation="mathml" ' \
                         'terminology-model="tbx"><custom-meta-group>' \
                         "<custom-meta><meta-name>guidelines</meta-name>" \
                         "<meta-value>2.1</meta-value></custom-meta>" \
                         "</custom-meta-group></processing-meta>",
        post_processors: [->(xml) { xml.gsub("Scope text.", "Scope NBSP text.") }],
      )

      oiml_xml = Metanorma::Document::Sts.convert(input_xml, profile: oiml_style)
      iso_xml = Metanorma::Document::Sts.convert(input_xml, profile: iso_style)

      # The OIML processing-meta shape (mathml attribute form).
      expect(oiml_xml).to include('mathml="MathML 3.0"')
      expect(oiml_xml).not_to include("guidelines")
      # The ISO processing-meta shape (mathml-version + custom-meta).
      expect(iso_xml).to include('mathml-version="3.0"')
      expect(iso_xml).to include("<meta-value>2.1</meta-value>")
      # The ISO profile's post-processor ran; the OIML profile's none.
      expect(iso_xml).to include("Scope NBSP text.")
      expect(oiml_xml).to include("Scope text.")
    ensure
      Metanorma::Document::Sts::Profiles.delete(oiml_style)
      Metanorma::Document::Sts::Profiles.delete(iso_style)
    end
  end

  describe ".validate" do
    it "delegates to the profile's validator class" do
      name = register(:"wave0_facade_validator_#{object_id}")
      profile = Metanorma::Document::Sts::Profiles.resolve(name)

      expect do
        Metanorma::Document::Sts.validate("<standard/>", profile: profile)
      end.to raise_error(ArgumentError, /no validator configured/)
    ensure
      Metanorma::Document::Sts::Profiles.delete(name)
    end
  end

  describe ".convert_to_model" do
    it "returns the typed sts-ruby Standard model" do
      name = register(:"wave0_facade_model_#{object_id}")
      model = Metanorma::Document::Sts.convert_to_model(input_xml,
                                                        profile: name)

      expect(model).to be_a(Sts::NisoSts::Standard)
      expect(model.to_xml).to include("<standard")
    ensure
      Metanorma::Document::Sts::Profiles.delete(name)
    end
  end
end
