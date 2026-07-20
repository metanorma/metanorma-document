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
    autoload :IsoRenderer, "metanorma/html/iso_renderer"
    autoload :BipmRenderer, "metanorma/html/bipm_renderer"
    autoload :CcRenderer, "metanorma/html/cc_renderer"
    autoload :CsaRenderer, "metanorma/html/csa_renderer"
    autoload :IccRenderer, "metanorma/html/icc_renderer"
    autoload :PdfaRenderer, "metanorma/html/pdfa_renderer"
    autoload :IecRenderer, "metanorma/html/iec_renderer"
    autoload :IeeeRenderer, "metanorma/html/ieee_renderer"
    autoload :IetfRenderer, "metanorma/html/ietf_renderer"
    autoload :IhoRenderer, "metanorma/html/iho_renderer"
    autoload :ItuRenderer, "metanorma/html/itu_renderer"
    autoload :OgcRenderer, "metanorma/html/ogc_renderer"
    autoload :OimlRenderer, "metanorma/html/oiml_renderer"
    autoload :RiboseRenderer, "metanorma/html/ribose_renderer"
  end
end
