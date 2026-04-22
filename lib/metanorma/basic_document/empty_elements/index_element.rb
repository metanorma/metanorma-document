# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module EmptyElements
      # Index term, defined as applying to the location in the text where the index element appears, as a
      # milestone.
      class IndexElement < Metanorma::BasicDocument::EmptyElements::BasicElement
        attribute :primary, :string
        attribute :secondary, :string
        attribute :tertiary, :string
        attribute :to, Metanorma::BasicDocument::IdElements::IdElement

        xml do
          element "index-xref"
          map_element "primary", to: :primary
          map_element "secondary", to: :secondary
          map_element "tertiary", to: :tertiary
          map_element "to", to: :to
        end
      end
    end
  end
end
