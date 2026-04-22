# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Change
      # Container for a multiple _ContentChangeAction_ data
      class ContentModify < Metanorma::BasicDocument::Change::ContentChange
        attribute :actions,
                  Metanorma::BasicDocument::Change::ContentChangeAction, collection: true

        xml do
          element "content-modify"
          map_element "actions", to: :actions
        end
      end
    end
  end
end
