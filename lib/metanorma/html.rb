# frozen_string_literal: true

require "metanorma/html/whitespace_patch"

module Metanorma
  module Html
    autoload :BaseRenderer, "metanorma/html/base_renderer"
    autoload :Generator, "metanorma/html/generator"
    autoload :Theme, "metanorma/html/theme"
    autoload :AssetPipeline, "metanorma/html/asset_pipeline"
    autoload :Component, "metanorma/html/component"
    autoload :Drops, "metanorma/html/drops"
    autoload :StandardRenderer, "metanorma/html/standard_renderer"
    autoload :IsoRenderer, "metanorma/html/iso_renderer"
    autoload :BipmRenderer, "metanorma/html/bipm_renderer"
    autoload :CcRenderer, "metanorma/html/cc_renderer"
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
