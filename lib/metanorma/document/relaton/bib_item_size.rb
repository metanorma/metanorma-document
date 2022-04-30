# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The size of a bibliographic item being referred to.
  #
  # A sequence of sizes can be used to indicate different numberings, e.g. xii + 40 pp.,
  # or different kinds of measures, e.g. pages + plates.
  class BibItemSize < Core::Node
    include Core::Node::Custom
  end
end; end; end
