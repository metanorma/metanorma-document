# frozen_string_literal: true

require "spec_helper"

# Spec-local step subclasses, defined outside the RSpec blocks (they
# are real classes, not stubs): exactly the shape the flavor gems ship
# in the adapter waves — engine classes, overridden public hooks, no
# engine edits, no monkey-patching.
module Wave0StructureHooks
  # Front matter: the foreword/introduction are <front> secs
  # (Guidelines 4.3.3/4.3.4: foreword unnumbered with
  # @sec-type='foreword', introduction with @sec-type='intro').
  class FrontInFrontTransformer <
      Metanorma::Document::Sts::Transformer::FrontTransformer
    def front_sections(source)
      sections = []
      sections += build_foreword(source) if source.foreword
      sections += build_introduction(source) if source.introduction
      sections
    end

    def build_foreword(source)
      content = dispatcher.dispatch_section_blocks(source.foreword)
      [Metanorma::Document::Sts::Transformer::ModelBuilder
        .sec(title: "Foreword", paragraph: content, sec_type: "foreword")]
    end

    def build_introduction(source)
      sec = section_transformer.transform(source.introduction)
      return [] unless sec

      sec.type = "intro"
      sec.title ||= ::Sts::NisoSts::Title.new(content: ["Introduction"])
      [sec]
    end
  end

  # The preface lives in the front, so the body carries only the
  # document's own sections.
  class NoPrefaceInBodyTransformer <
      Metanorma::Document::Sts::Transformer::BodyTransformer
    def include_preface_in_body?
      false
    end
  end
end

# Structure-hook proofs for the STS engine (metanorma-document#165):
#
# 1. The engine default maps the preface (foreword/introduction) into
#    the BODY — the neutral, OIML-style structure.
# 2. A publisher whose structure differs — the ISO profile puts the
#    foreword and introduction in <front> with @sec-type, and drops
#    them from the body — replaces the steps with registered
#    SUBCLASSES via the profile's class-override registry.
#
# The same source document converts differently under the two
# profiles — nothing in the engine assumes one document structure.
RSpec.describe "STS engine structure hooks" do
  let(:reader) { Metanorma::Iso::Document::Root }

  let(:input_xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation" flavor="iso">
        <bibdata type="standard">
          <title language="en" type="main">Hooks spec doc</title>
          <docidentifier primary="true" type="ISO">ISO 2</docidentifier>
          <language>en</language>
        </bibdata>
        <preface>
          <foreword id="fw"><p>Foreword body text.</p></foreword>
        </preface>
        <sections>
          <clause id="c1" type="scope"><title>Scope</title><p id="p1">Scope text.</p></clause>
        </sections>
      </metanorma>
    XML
  end

  def register_profile(name, overrides)
    Metanorma::Document::Sts::Profiles.register(
      Metanorma::Document::Sts::Profile.new(
        name: name,
        dtd_version: "1.0",
        reader_class: reader,
        class_overrides: overrides,
      ),
    )
  end

  def convert_with(profile_name)
    Metanorma::Document::Sts.convert(input_xml, profile: profile_name)
  end

  describe "the neutral default (preface in the body)" do
    let(:profile_name) { :"wave0_hooks_neutral_#{object_id}" }

    before { register_profile(profile_name, {}) }

    after { Metanorma::Document::Sts::Profiles.delete(profile_name) }

    it "emits the foreword as a body section" do
      xml = convert_with(profile_name)
      body = xml[/<body>.*<\/body>/m]

      expect(body).to include("<title>Foreword</title>")
      expect(body).to include("Foreword body text.")
    end

    it "emits no foreword sec inside <front>" do
      xml = convert_with(profile_name)
      front = xml[/\A.*?<body>/m]

      expect(front).not_to include("<title>Foreword</title>")
    end
  end

  describe "the ISO-style structure (preface in <front>, via registered subclasses)" do
    let(:profile_name) { :"wave0_hooks_front_#{object_id}" }

    before do
      register_profile(
        profile_name,
        Metanorma::Document::Sts::Transformer::FrontTransformer =>
          Wave0StructureHooks::FrontInFrontTransformer,
        Metanorma::Document::Sts::Transformer::BodyTransformer =>
          Wave0StructureHooks::NoPrefaceInBodyTransformer,
      )
    end

    after { Metanorma::Document::Sts::Profiles.delete(profile_name) }

    it "emits the foreword as a front sec carrying @sec-type" do
      xml = convert_with(profile_name)
      front = xml[/\A.*?<body>/m]

      expect(front).to include("<title>Foreword</title>")
      expect(front).to include('type="foreword"')
      expect(front).to include("Foreword body text.")
    end

    it "does not emit the foreword in the body" do
      xml = convert_with(profile_name)
      body = xml[/<body>.*<\/body>/m]

      expect(body).not_to include("<title>Foreword</title>")
      expect(body).not_to include("Foreword body text.")
      expect(body).to include("<title>Scope</title>")
    end
  end

  describe "step resolution" do
    it "rides Context#build: the profile override constructs the subclass" do
      profile_name = :"wave0_hooks_ctx_#{object_id}"
      register_profile(
        profile_name,
        Metanorma::Document::Sts::Transformer::BodyTransformer =>
          Wave0StructureHooks::NoPrefaceInBodyTransformer,
      )
      profile = Metanorma::Document::Sts::Profiles.resolve(profile_name)
      source = Metanorma::Document::Sts::Transformer::SourceDocument
        .parse(input_xml, profile: profile)
      context = Metanorma::Document::Sts::Transformer::Context
        .new(source, profile: profile)

      resolved = context
        .build(Metanorma::Document::Sts::Transformer::BodyTransformer)
        .new(context)
      expect(resolved).to be_a(Wave0StructureHooks::NoPrefaceInBodyTransformer)
      expect(resolved.include_preface_in_body?).to be(false)
      expect(resolved.context).to equal(context)

      # An unregistered step resolves to the engine class.
      plain = context
        .build(Metanorma::Document::Sts::Transformer::DlTransformer)
      expect(plain).to eq(Metanorma::Document::Sts::Transformer::DlTransformer)

      Metanorma::Document::Sts::Profiles.delete(profile_name)
    end
  end
end
