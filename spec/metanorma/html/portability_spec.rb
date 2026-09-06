# frozen_string_literal: true

require "spec_helper"

# OCP gate: metanorma-document is the harness — it must carry zero
# flavour knowledge. Adding a flavour means a new repository plus a
# register_flavor call there; it must never mean a change here. This
# spec turns that property into an executable invariant.
FLAVOR_NAMESPACES = %w[
  Iso Bipm Bsi Cc Csa Gb Iec Ieee Ietf Iho Itu Jis M3aawg M3d Mpfa
  Nist Ogc Ribose Un Plateau Icc Pdfa
].freeze
# NEXT OCP FRONT: lib/metanorma/mirror/default_registry.rb still
# carries guarded iso/un handler registrations; extracting them needs
# a pre-build registration seam on the mirror side. Everything else
# is gated.
MIRROR_EXCEPTION = "lib/metanorma/mirror/default_registry.rb"
# Top-level aliases (Metanorma::IsoDocument & friends) are flavour
# knowledge too — the collection models once typed bibdata/embedded
# documents against them, fatal-loading every non-iso-family bundle.
FLAVOR_ALIASES = FLAVOR_NAMESPACES.map { |n| "Metanorma::#{n}Document" }.freeze

RSpec.describe "harness portability (OCP gate)" do
  it "lib/metanorma references no flavor namespaces" do
    pattern = /\bMetanorma::(#{FLAVOR_NAMESPACES.join('|')})\b/
    hits = Dir["lib/metanorma/**/*.rb"].reject { |f| f == MIRROR_EXCEPTION }.flat_map do |f|
      File.readlines(f).each_with_index.filter_map do |line, i|
        "#{f}:#{i + 1}: #{line.strip}" if line.match?(pattern)
      end
    end
    expect(hits).to be_empty,
                    "flavour knowledge leaked into the harness:\n#{hits.join("\n")}"
  end

  it "lib/metanorma references no flavor document aliases" do
    hits = Dir["lib/metanorma/**/*.rb"].reject { |f| f == MIRROR_EXCEPTION }.flat_map do |f|
      File.readlines(f).each_with_index.filter_map do |line, i|
        "#{f}:#{i + 1}: #{line.strip}" if FLAVOR_ALIASES.any? { |a| line.include?(a) }
      end
    end
    expect(hits).to be_empty,
                    "flavour alias leaked into the harness:\n#{hits.join("\n")}"
  end

  it "ships no flavor-prefixed templates or theme assets" do
    prefixes = FLAVOR_NAMESPACES.map { |n| "_#{n.downcase}_" }
    hits = Dir["lib/metanorma/html/templates/*"].select do |t|
      prefixes.any? { |p| File.basename(t).start_with?(p) }
    end
    expect(hits).to be_empty, "flavour-named templates in the harness: #{hits}"
  end

  it "registers no flavor renderers at load time" do
    loaded = $LOADED_FEATURES.grep(%r{metanorma/html/.*_renderer})
    flavor_renderers = loaded.grep(/(?:#{FLAVOR_NAMESPACES.map(&:downcase).join('|')})_renderer/)
    expect(flavor_renderers).to be_empty
  end
end
