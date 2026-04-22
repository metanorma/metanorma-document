# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The name of a person.
      class FullName < Lutaml::Model::Serializable
        attribute :prefix, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true
        attribute :forename, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true
        attribute :initials, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true
        attribute :surname, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :addition, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true
        attribute :complete_name, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :note, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :variant, VariantFullName, collection: true

        xml do
          map_element "prefix", to: :prefix
          map_element "forename", to: :forename
          map_element "initials", to: :initials
          map_element "surname", to: :surname
          map_element "addition", to: :addition
          map_element "completename", to: :complete_name
          map_element "note", to: :note
          map_element "variant", to: :variant
        end
      end
    end
  end
end
