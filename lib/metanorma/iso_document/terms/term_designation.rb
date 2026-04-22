# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      # Designation of a term (preferred, admitted, deprecates, etc.)
      class TermDesignation < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :expression, TermExpression
        attribute :source, TermSource, collection: true

        xml do
          map_attribute "id", to: :id
          map_element "expression", to: :expression
          map_element "source", to: :source
        end
      end
    end
  end
end
