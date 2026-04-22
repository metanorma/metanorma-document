# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Lists
      # Definition list, composed of definitions rather than list items.
      class DefinitionList < Metanorma::BasicDocument::Lists::List
        attribute :listitem, Metanorma::BasicDocument::Lists::Definition,
                  collection: true

        xml do
          element "dl"
          map_element "listitem", to: :listitem
        end
      end
    end
  end
end
