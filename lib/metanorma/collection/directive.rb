# frozen_string_literal: true

module Metanorma
  module Collection
    # A key-value directive in a metanorma-collection.
    # Directives control collection behavior (e.g., documents-inline, flavor).
    class Directive < Lutaml::Model::Serializable
      attribute :key, :string
      attribute :value, :string

      xml do
        element "directive"
        map_element "key", to: :key
        map_element "value", to: :value
      end
    end
  end
end
