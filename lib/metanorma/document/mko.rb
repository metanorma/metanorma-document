# frozen_string_literal: true

require "metanorma/mko"
require "metanorma-core"
require "nokogiri"

module Metanorma
  # The MODEL side of MKO (MN 116), reopening the format gem's module:
  # the projection walk (Project), collection orchestration
  # (Collection), the compile-pipeline exporter, flavor resolution and
  # registry seeding, and the export entry points. The wire contract —
  # schema, bundle layout, assets, diffs, alignment, JSON Schemas, the
  # MCP server — lives in the metanorma-mko gem.
  module Mko
    autoload :Project, "metanorma/document/mko/project"
    autoload :Collection, "metanorma/document/mko/collection"
    autoload :Exporter, "metanorma/document/mko/exporter"

    class << self
      # Export a document model (or semantic/presentation XML string)
      # as an MKO bundle directory (or .mko.zip with zip: true).
      # Returns an Export (path + projection Result); the Export
      # ducktypes as the bundle path String for existing callers.
      def export(source, to:, presentation_xml: nil, zip: false,
                 assets_from: nil)
        seed_flavors!
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
        seed_flavors!
        renderer_for(document, **)
          .new.generate_full_document(document, **)
      end

      def renderer_for(document, **)
        seed_flavors!
        Metanorma::Core::Flavors.renderer_for(document, format: :mko,
                                                        **) || Exporter
      end

      private

      def model_from_xml(xml)
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

    # Lazy: seeding touches the core flavor registry, which only the
    # flavor-table line of metanorma-core defines. Requiring this gem
    # must never depend on it — seeds on first use, no-op without it.
    class << self
      def seed_flavors!
        return unless defined?(Metanorma::Core::Flavors)
        return if @flavors_seeded

        @flavors_seeded = true
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
      end
    end
  end

  # document.rb keeps the lazy entry that pulls the model side in
  Document.autoload :MkoIntegration, "metanorma/document/mko" if false
end
