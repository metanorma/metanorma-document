# frozen_string_literal: true

require "metanorma-core"
require "lutaml/model"
require "json"
require "digest"
require "zlib"

module Metanorma
  # Metanorma Knowledge Objects (MKO) — the machine serialization of a
  # Metanorma document as a bundle of typed, addressable knowledge
  # objects (metanorma/metanorma#592). A derived projection over the
  # typed document model: like a rendering, never a source format.
  module Mko
    autoload :Schema, "metanorma/mko/schema"
    autoload :Project, "metanorma/mko/project"
    autoload :Writer, "metanorma/mko/writer"
    autoload :Exporter, "metanorma/mko/exporter"
    autoload :Export, "metanorma/mko/export"
    autoload :Diff, "metanorma/mko/diff"
    autoload :Assets, "metanorma/mko/assets"
    autoload :Bundle, "metanorma/mko/bundle"
    autoload :Collection, "metanorma/mko/collection"
    autoload :Alignment, "metanorma/mko/alignment"

    SCHEMA = "metanorma-mko"
    SCHEMA_VERSION = "1.0.0"

    # Same seeding pattern as Html in html.rb: contribute the mko
    # renderer for the two harness model trees. Flavor models do not
    # subclass the harness roots (they include RootAttributes), so
    # renderer resolution for :mko goes through .renderer_for below with
    # a harness fallback — the Html::Generator pattern. Core::Flavors
    # has no add_renderer API yet — attach to the entry html.rb
    # registered when present, register a standalone entry otherwise
    # (mko loaded without html); delete the attach branch when core
    # gains the mutator.
    SEED_MODEL_ROOTS = {
      document: Metanorma::Document::Root,
      standoc: "Metanorma::Standoc::Document::Root",
    }.freeze

    SEED_MODEL_ROOTS.each do |seed, model_root|
      entry = Metanorma::Core::Flavors.find(seed)
      if entry
        entry.renderers[:mko] ||= Exporter
      else
        Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
                                            name: seed,
                                            model_root: model_root,
                                            renderers: { mko: Exporter },
                                          ))
      end
    end

    class << self
      # Export a document model (or semantic/presentation XML string)
      # as an MKO bundle directory (or .mko.zip with zip: true).
      # Returns the bundle path.
      def export(source, to:, presentation_xml: nil, zip: false,
                 assets_from: nil)
        model = source.is_a?(String) ? model_from_xml(source) : source
        presentation = case presentation_xml
                       when String then model_from_xml(presentation_xml)
                       when nil then nil
                       else presentation_xml
                       end
        projection = Project.call(model, presentation: presentation,
                                         assets: Assets.new(source_dir: assets_from))
        Export.new(Writer.write(projection, to: to, zip: zip), projection)
      end

      # The format adapter over the central flavor registry (mirrors
      # Html::Generator): a flavor entry may register its own :mko
      # renderer; with none, the harness Exporter serves any model tree
      # — the walk is class/attribute-driven, zero flavor knowledge.
      def generate(document, **)
        renderer_for(document, **)
          .new.generate_full_document(document, **)
      end

      # The published wire contract, generated from the schema
      # classes: name => JSON Schema (draft 2020-12). MN 116 ships
      # these alongside the spec text.
      # Canonical short-id derivation (one rule, used by documents and
      # collections alike).
      def slug(canonical)
        canonical.to_s.tr(" ", "-").gsub(/[^A-Za-z0-9.-]/, "")
          .squeeze("-").downcase
      end

      def json_schemas
        Schema::JsonSchema.all
      end

      def renderer_for(document, **)
        Metanorma::Core::Flavors.renderer_for(document, format: :mko,
                                                        **) || Exporter
      end

      private

      def model_from_xml(xml)
        require "nokogiri"
        root = Nokogiri::XML(xml).root
        flavor = root["flavor"]
        klass = nil
        Metanorma::Core::Flavors.table.reverse_each do |entry|
          next if entry.taste?

          candidate = entry.model_root_class or next
          name = entry.name.to_s
          next if flavor && !flavor.empty? && name != flavor

          klass = candidate
          break
        end
        unless klass
          raise ArgumentError,
                "no document model registered for flavor #{flavor.inspect}; " \
                "require the flavor gem (metanorma-standoc or a flavor) " \
                "before exporting"
        end

        klass.from_xml(xml)
      end
    end
  end
end
