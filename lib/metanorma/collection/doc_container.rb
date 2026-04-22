# frozen_string_literal: true

module Metanorma
  module Collection
    # A container for an embedded document within a metanorma-collection.
    # Each doc-container holds one <metanorma> document identified by its id attribute.
    class DocContainer < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :document, Metanorma::IsoDocument::Root

      xml do
        element "doc-container"
        map_attribute "id", to: :id
        map_element "metanorma", to: :document
      end
    end
  end
end
