# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The extent or location of a bibliographic item being referred to.
  #
  # A sequence of locality elements is meant to indicate hierarchical ordering,
  # from greater to smaller.
  #
  # [example]
  # Chapter, then page, then paragraph.
  #
  # A discontinuous range can be represented by using two adjacent localities
  # with the same type.
  class BibItemLocality < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of extent (e.g. section, clause, page).
      attribute :type, SpecificLocalityType

      # The starting value of the extent, or point location.
      nodes :reference_from, BasicDocument::LocalizedString

      # The end value of the extent as a range, if applicable.
      nodes :reference_to, BasicDocument::LocalizedString
    end
  end
end; end; end
