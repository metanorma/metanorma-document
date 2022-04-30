# frozen_string_literal: true

require "relaton/locality_stack"

module Metanorma; module Document; module StandardDocument
  # Description of location in a reference, which can be combined with other locations in a single
  # citation.
  class StandocLocalityStack < Relaton::LocalityStack
    register_element do
      # Connective linking this location to its predecessor. _from/to_ are presumed to nest more closely
      # than _and_ or _or_.
      attribute :connective, XrefConnectiveType
    end
  end
end; end; end
