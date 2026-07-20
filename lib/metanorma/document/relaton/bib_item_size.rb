# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      # The size of a bibliographic item being referred to.
      # relaton-bib's <size><value type>text</value></size> grammar matches
      # metanorma biblio.rng; this gem's previous grammar had +type+ on
      # +size+ itself and a singular +value+.
      class BibItemSize < ::Relaton::Bib::Size
        # Compatibility reader: relaton-bib carries +type+ on each +value+.
        def type = value&.first&.type
      end
    end
  end
end
