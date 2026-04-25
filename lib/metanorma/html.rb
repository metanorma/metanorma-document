# frozen_string_literal: true

module Metanorma
  module Html
    autoload :BaseRenderer, "metanorma/html/base_renderer"
    autoload :Generator, "metanorma/html/generator"
    autoload :IndexGenerator, "metanorma/html/index_generator"
    autoload :IsoRenderer, "metanorma/html/iso_renderer"
    autoload :Renderer, "metanorma/html/renderer"
    autoload :StandardRenderer, "metanorma/html/standard_renderer"
    autoload :Transformer, "metanorma/html/transformer"
  end
end
