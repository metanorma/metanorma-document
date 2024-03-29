# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # A digital signature of the contribution, consisting of a `hash` value and a `signature`, with an
  # associated `publicKey`.
  class IntegrityValue < Core::Node
    include Core::Node::Custom

    register_element
  end
end; end; end
