# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The size of a bibliographic item being referred to.
  #
  # A sequence of sizes can be used to indicate different numberings, e.g. xii + 40 pp.,
  # or different kinds of measures, e.g. pages + plates.
  class BibItemSize < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of size (e.g. volumes, pages, megabytes)
      attribute :type, BibItemSizeType

      # The quantity of the size
      nodes :value, BasicDocument::LocalizedString
    end
  end
end; end; end
