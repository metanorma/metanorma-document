# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Document::Presentation::ProfileLoader do
  let(:presentation) { Metanorma::Document::Presentation }
  let(:fixture) { File.expand_path("../../../fixtures/presentation/profiles.lml", __dir__) }
  let(:layers) { described_class.from_file(fixture) }

  def resolve(**opts)
    presentation::LayeredProfile.resolve(layers, **opts).settings
  end

  it "loads LML layers" do
    expect(layers.map(&:name)).to eq(%w[base iso ieee iso_cs])
    expect(layers.map(&:layer)).to eq(%w[base flavor flavor taste])
  end

  it "uses the base layer alone" do
    expect(resolve).to eq("date_format" => "%Y-%m-%d", "footnote_marker" => "numeric", "footnote_sup" => true,
                          "order" => "ab")
  end

  it "lets a flavor override base key by key" do
    expect(resolve(flavor: "iso")).to eq("date_format" => "%d %B %Y",
                                         "footnote_marker" => "alpha", "footnote_sup" => true, "order" => "ab")
  end

  it "lets a taste override its flavor, replacing a value" do
    expect(resolve(flavor: "iso", taste: "iso_cs")).to eq(
      "date_format" => "%d %B %Y", "footnote_marker" => "alpha", "footnote_sup" => false, "order" => "z",
    )
  end

  it "ignores a taste whose flavor is not selected" do
    expect(resolve(flavor: "ieee", taste: "iso_cs").slice("footnote_sup", "date_format"))
      .to eq("footnote_sup" => true, "date_format" => "%B %d, %Y")
  end

  it "yields the same layers from the YAML twin" do
    yaml = <<~Y
      schema: mn116/1
      instances:
      - name: base
        type: PresentationProfile
        properties: { layer: base, settings: { a: 1 } }
    Y
    expect(described_class.from_yaml(yaml).first.settings).to eq("a" => 1)
  end

  it "produces a profile that is a no-op for the engine" do
    profile = presentation::LayeredProfile.resolve(layers, flavor: "iso")
    expect(profile).to be_noop
    expect(profile.settings["date_format"]).to eq("%d %B %Y")
  end

  describe "invalid profiles" do
    def lml(props, type: "PresentationProfile")
      %(#{type} "bad" {\n#{props}\n}\n)
    end

    it "locates an unknown layer" do
      expect { described_class.from_lml(lml(%(  layer = "city")), source: "p.lml") }
        .to raise_error(presentation::ProfileError, /p\.lml, line 2, instance bad, property layer: must be one of/)
    end

    it "locates a missing flavor on a flavor layer" do
      expect { described_class.from_lml(lml(%(  layer = "flavor")), source: "p.lml") }
        .to raise_error(presentation::ProfileError, /instance bad, property flavor: required for a flavor layer/)
    end

    it "rejects an unknown property and a wrong type" do
      expect { described_class.from_lml(lml(%(  layer = "base"\n  colour = "red"))) }
        .to raise_error(presentation::ProfileError, /property colour: unknown property/)
      expect { described_class.from_lml(lml(%(  layer = "base"), type: "Other")) }
        .to raise_error(presentation::ProfileError, /type must be PresentationProfile/)
    end

    it "rejects a nested map value" do
      yaml = "schema: mn116/1\ninstances:\n- name: b\n  type: PresentationProfile\n  properties:\n    layer: base\n    settings:\n      a: {b: 1}\n"
      expect { described_class.from_yaml(yaml, source: "p.yaml") }
        .to raise_error(presentation::ProfileError, /p\.yaml, line \d+, instance b, property settings\.a: must be a scalar/)
    end

    it "rejects duplicate names and malformed LML and YAML" do
      two = lml(%(  layer = "base")) * 2
      expect { described_class.from_lml(two) }.to raise_error(presentation::ProfileError, /duplicate instance name/)
      expect { described_class.from_lml("PresentationProfile {") }.to raise_error(presentation::ProfileError, /invalid LML/)
      expect { described_class.from_yaml("schema: [") }.to raise_error(presentation::ProfileError, /invalid YAML/)
      expect { described_class.from_yaml("schema: other\ninstances: []") }
        .to raise_error(presentation::ProfileError, /expected schema mn116\/1/)
    end

    it "rejects two layers of one kind for the same selection" do
      same = layers + [described_class.from_lml(%(PresentationProfile "iso2" {\n layer = "flavor"\n flavor = "iso"\n}\n)).first]
      expect { presentation::LayeredProfile.resolve(same, flavor: "iso") }
        .to raise_error(presentation::ProfileError, /more than one flavor layer/)
    end
  end
end
