# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Lists
      # List block.
      class List < Metanorma::BasicDocument::Blocks::BasicBlock
        attribute :listitem, BasicObject, collection: true

        xml do
          element "list"
          map_element "listitem", to: :listitem
        end
      end
    end
  end
end
