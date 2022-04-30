# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The content of mathematically formatted text.
  class StemValue < Core::Node
    include Core::Node::Custom

    register_element
  end
end; end; end
