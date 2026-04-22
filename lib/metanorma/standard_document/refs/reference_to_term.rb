# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Refs
      # Cross-reference to a term.
      class ReferenceToTerm < Metanorma::Document::Components::ReferenceElements::ReferenceElement
        attribute :source, BasicObject
        attribute :term, :string, collection: true

        attribute :semx_id, :string
        attribute :original_id, :string

        xml do
          element "reference-to-term"
          map_element "source", to: :source
          map_element "term", to: :term

          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
        end
      end
    end
  end
end
