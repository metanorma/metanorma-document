# frozen_string_literal: true

require "basic_document/emptyelements/basic_element"

module Metanorma; module Document; module BasicDocument
  # Index term, defined as applying to the location in the text where the index element appears, as a
  # milestone.
  class IndexElement < BasicElement
    register_element do
      # Primary index term to be recorded at the current location.
      attribute :primary, String

      # Secondary index term to be recorded at the current location.
      nodes :secondary, String

      # Tertiary index term to be recorded at the current location.
      nodes :tertiary, String

      # A reference to an ID element (typically a bookmark),
      # to indicate that the index range covers a range of locations.
      nodes :to, IdElement
    end
  end
end; end; end
