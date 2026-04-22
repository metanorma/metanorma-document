# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A description of the role of the contributor in the production of a bibliographic item.
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
