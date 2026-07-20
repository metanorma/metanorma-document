# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A description of the role of the contributor in the production of a bibliographic item.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Contributor::Role
      # has no mixed content (BIPM fixture: <role type="editor">Author for
      # correspondence</role>) and sanitizes description markup.
      class ContributorRole < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :description,
                  Metanorma::Document::Components::DataTypes::FormattedString, collection: true
        attribute :text, :string, collection: true

        xml do
          element "role"
          mixed_content
          map_attribute "type", to: :type
          map_content to: :text
          map_element "description", to: :description
        end
      end
    end
  end
end
