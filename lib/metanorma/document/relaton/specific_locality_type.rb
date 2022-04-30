# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Type of indicator of a location or extent within a bibliographic item.
  #
  # When the value `whole` or `title` is used, the corresponding `BibItemLocality`
  # attribute `identifier` should be empty.
  class SpecificLocalityType < Core::Node::Enum
  end
end; end; end
