# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # A name under which a managed term is known.
  class Designation < Core::Node
    include Core::Node::Custom

    register_element do
      # Indication that the term designation is missing.
      nodes :absent, TrueClass

      # The geographic area in which the managed term is known under this designation.
      nodes :geographic_area, BasicDocument::Iso3166Code

      # Bibliographic references for this designation of the managed term.
      nodes :sources, TermSource
    end
  end
end; end; end
