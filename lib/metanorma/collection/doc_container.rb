# frozen_string_literal: true

module Metanorma
  module Collection
    # A container for an embedded document within a metanorma-collection.
    # Each doc-container holds one <metanorma> document identified by its id attribute.
    class DocContainer < Lutaml::Model::Serializable
      attribute :id, :string
      # Embedded documents belong to whichever flavor authored them; the
      # harness carries only the neutral base root. Flavor-faithful parsing
      # arrives with lutaml polymorphic differentiators (subclass roots
      # declaring polymorphic_class: true), not by typing against a flavor.
      attribute :document, Metanorma::Document::Root

      xml do
        element "doc-container"
        map_attribute "id", to: :id
        map_element "metanorma", to: :document
      end
    end
  end
end
