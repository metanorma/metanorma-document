# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Change
      # Possible actions
      # that involve modification of an attribute within a BasicDocument
      # data element.
      class AttributeChangeAction < Metanorma::BasicDocument::Change::ContentChangeAction
        attribute :attribute_id, :string

        xml do
          element "attribute-change-action"
          map_attribute "attribute-id", to: :attribute_id
        end
      end
    end
  end
end
