# frozen_string_literal: true

require "liquid"
require "nokogiri"

module Metanorma
  module Html
    unless defined?(TEMPLATES_ROOT)
      TEMPLATES_ROOT = File.join(__dir__, "html", "templates")

      Liquid::Environment.default.file_system = Liquid::LocalFileSystem.new(
        TEMPLATES_ROOT, "_%s.html.liquid"
      )
    end

    autoload :BaseRenderer, "metanorma/html/base_renderer"
    autoload :Flavor, "metanorma/html/flavor"
    autoload :FlavorRegistry, "metanorma/html/flavor_registry"
    autoload :Generator, "metanorma/html/generator"
    autoload :RendererDelegation, "metanorma/html/renderer_delegation"
    autoload :Theme, "metanorma/html/theme"
    autoload :AssetPipeline, "metanorma/html/asset_pipeline"
    autoload :Component, "metanorma/html/component"
    autoload :Drops, "metanorma/html/drops"
    autoload :StandardRenderer, "metanorma/html/standard_renderer"

    class << self
      # The process-wide flavor registry. The harness seeds only its own
      # defaults (generic document + Standoc); flavour gems register
      # themselves at load time via #register_flavor. Nothing in this
      # gem registers a flavour.
      def flavors
        @flavors ||= FlavorRegistry.new
      end

      # Write-side of the extension seam: flavour gems call this from
      # their own load path with their Flavor entry (model class,
      # renderer class, pubid module). Most-specific-wins ancestry
      # matching means a flavour can re-base its renderer by changing
      # only its own registration.
      def register_flavor(flavor)
        flavors.register(flavor)
      end
    end

    # Harness defaults: the two model trees this gem ships renderers
    # for. Registered first so flavour entries (registered later) win
    # the most-specific match.
    register_flavor(Flavor.new(
                      name: nil,
                      model_class: Metanorma::Document::Root,
                      renderer_class: BaseRenderer,
                    ))
    register_flavor(Flavor.new(
                      name: nil,
                      model_class: "Metanorma::Standoc::Document::Root",
                      renderer_class: StandardRenderer,
                    ))
  end
end
