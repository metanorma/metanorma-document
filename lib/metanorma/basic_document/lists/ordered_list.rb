# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Lists
      # Ordered list, with numbering applied to the list items.
      class OrderedList < Metanorma::BasicDocument::Lists::UnorderedList
        attribute :type, :string
        attribute :start, :string

        xml do
          element "ol"
          map_attribute "type", to: :type
          map_element "start", to: :start
        end
      end
    end
  end
end
