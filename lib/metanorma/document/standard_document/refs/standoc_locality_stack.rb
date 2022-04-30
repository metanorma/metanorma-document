# frozen_string_literal: true

require "relaton/locality_stack"

module Metanorma; module Document; module StandardDocument
  # Description of location in a reference, which can be combined with other locations in a single
  # citation.
  class StandocLocalityStack < Relaton::LocalityStack
  end
end; end; end
