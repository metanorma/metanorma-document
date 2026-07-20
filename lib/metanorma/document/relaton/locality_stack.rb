# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      # Hierarchical arrangement of bibliographic localities.
      class LocalityStack < ::Relaton::Bib::LocalityStack
        # Compatibility alias: relaton-bib names the collection
        # +locality+, this gem historically used +bib_locality+.
        def bib_locality = locality
      end
    end
  end
end
