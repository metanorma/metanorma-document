# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      # The name of a person.
      # Inherits relaton-bib's FullName, gaining the formatted-initials and
      # abbreviation element mappings (formatted-initials was previously
      # dropped on round-trip). The mappings below are re-declared with
      # Metanorma's richer LocalizedString and variant wrapper — relaton-bib
      # 2.2.0.pre.alpha.1 types note as a sanitized Note collection and
      # inlines the variant name fields.
      class FullName < ::Relaton::Bib::FullName
        attribute :prefix, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true
        attribute :forename, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true
        attribute :initials, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true
        attribute :surname, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :addition, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true
        attribute :completename, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :note, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :variant, VariantFullName, collection: true

        # Compatibility reader: relaton-bib names the attribute completename.
        def complete_name = completename

        xml do
          map_element "prefix", to: :prefix
          map_element "forename", to: :forename
          map_element "initials", to: :initials
          map_element "surname", to: :surname
          map_element "addition", to: :addition
          map_element "completename", to: :completename
          map_element "note", to: :note
          map_element "variant", to: :variant
        end
      end
    end
  end
end
