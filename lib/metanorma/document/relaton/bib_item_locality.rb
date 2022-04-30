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
  end
end; end; end
