# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::Sts::Profiles do
  # A uniquely-named profile so the global registry never collides
  # with another spec's registrations.
  let(:profile_name) { :"wave0_spec_profile_#{object_id}" }

  after do
    described_class.delete(profile_name)
  end

  describe ".register and .resolve" do
    it "resolves a registered profile by name" do
      profile = Metanorma::Document::Sts::Profile.new(
        name: profile_name,
        org_abbrev: "TST",
        dtd_version: "9.9",
      )
      described_class.register(profile)

      expect(described_class.resolve(profile_name)).to equal(profile)
      expect(described_class.fetch(profile_name)).to equal(profile)
      expect(described_class.names).to include(profile_name)
    end

    it "replaces a prior registration under the same name" do
      first = Metanorma::Document::Sts::Profile.new(name: profile_name)
      second = Metanorma::Document::Sts::Profile.new(name: profile_name,
                                                     dtd_version: "2.2")
      described_class.register(first)
      described_class.register(second)

      expect(described_class.resolve(profile_name)).to equal(second)
    end

    it "raises KeyError naming the registered profiles for an unknown name" do
      described_class.register(
        Metanorma::Document::Sts::Profile.new(name: :wave0_other_profile),
      )

      expect { described_class.resolve(profile_name) }
        .to raise_error(KeyError, /wave0_other_profile/)
    end

    it "refuses non-Profile registrations" do
      expect { described_class.register("not a profile") }
        .to raise_error(ArgumentError, /not a.*Profile/)
    end
  end

  describe ".default" do
    it "carries the neutral profile: no publisher identity, no overrides" do
      default = described_class.default

      expect(default.name).to eq(:default)
      expect(default.org_abbrev).to be_nil
      expect(default.custom_meta).to be_nil
      expect(default.class_overrides).to be_empty
      expect(default.term_classes).to be_empty
    end
  end

  describe "a registered profile" do
    describe "#resolve" do
      let(:base) { Metanorma::Document::Sts::Transformer::DlTransformer }

      it "returns the registered subclass for an overridden step" do
        subclass = Class.new(base)
        profile = Metanorma::Document::Sts::Profile.new(
          name: profile_name,
          class_overrides: { base => subclass },
        )

        expect(profile.resolve(base)).to equal(subclass)
        expect(profile.overrides?(base)).to be(true)
      end

      it "returns the engine class when the profile registers no override" do
        profile = Metanorma::Document::Sts::Profile.new(name: profile_name)

        expect(profile.resolve(base)).to equal(base)
        expect(profile.overrides?(base)).to be(false)
      end
    end
  end
end
