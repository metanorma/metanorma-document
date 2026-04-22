# frozen_string_literal: true

require "nokogiri"

module Metanorma
  module Html
    autoload :IndexGenerator, "metanorma/html/index_generator"
    autoload :Renderer, "metanorma/html/renderer"
    autoload :Transformer, "metanorma/html/transformer"
  end
end
