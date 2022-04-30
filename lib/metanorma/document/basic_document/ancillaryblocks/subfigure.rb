# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # A figure embedded within another figure.
  # Subfigures only occur within figures.
  class Subfigure < Core::Node
    include Core::Node::Custom
  end
end; end; end
