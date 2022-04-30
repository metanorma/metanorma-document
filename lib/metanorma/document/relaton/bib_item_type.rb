# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Type of bibliographic item.
  #
  # The value list complies with the types provided in ISO 690:2021.
  #
  # NOTE: These values represent a strict superset to BibTeX
  # publication types, and therefore any BibTeX type value can be
  # mapped to these values. Some values here do not have a corresponding
  # entry in BibTeX, for instance, "standard" and "website".
  #
  # NOTE: While the value of "electronicResource" exists, the
  # distinction between offline and online resources
  # should be made through medium (electronic vs physical).
  class BibItemType < Core::Node::Enum
  end
end; end; end
