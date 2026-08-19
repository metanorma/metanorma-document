# frozen_string_literal: true

require "liquid"
require "metanorma-core"
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
    autoload :Generator, "metanorma/html/generator"
    autoload :RendererDelegation, "metanorma/html/renderer_delegation"
    autoload :Theme, "metanorma/html/theme"
    autoload :AssetPipeline, "metanorma/html/asset_pipeline"
    autoload :Component, "metanorma/html/component"
    autoload :Drops, "metanorma/html/drops"
    autoload :StandardRenderer, "metanorma/html/standard_renderer"

    # This module is a pure format adapter over the central flavor
    # registry (Metanorma.flavors). It contributes the HTML renderers
    # for the two model trees the harness ships — that is the extent of
    # its registration. Flavor gems register their own entries from
    # their load paths; nothing here knows a flavor.
    Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
                                        name: :document,
                                        model_root: Metanorma::Document::Root,
                                        renderers: { html: BaseRenderer },
                                      ))
    Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
                                        name: :standoc,
                                        model_root: "Metanorma::Standoc::Document::Root",
                                        renderers: { html: StandardRenderer },
                                      ))
  end
end
