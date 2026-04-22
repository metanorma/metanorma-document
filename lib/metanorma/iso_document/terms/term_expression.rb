# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      # Name element inside a term expression.
      # Has id and semx-id attributes in presentation XML.
      # Contains mixed content with inline elements like strike, em, etc.
      class TermNameElement < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :semx_id, :string
        attribute :lang, :string
        attribute :text, :string, collection: true
        attribute :strike, Metanorma::Document::Components::TextElements::StrikeElement,
                  collection: true
        attribute :em, Metanorma::Document::Components::Inline::EmRawElement,
                  collection: true
        attribute :strong, Metanorma::Document::Components::Inline::StrongRawElement,
                  collection: true
        attribute :sup, Metanorma::Document::Components::Inline::SupElement,
                  collection: true
        attribute :sub, Metanorma::Document::Components::Inline::SubElement,
                  collection: true

        xml do
          element "name"
          map_attribute "id", to: :id
          map_attribute "semx-id", to: :semx_id
          map_attribute "lang", to: :lang
          mixed_content
          map_content to: :text
          map_element "strike", to: :strike
          map_element "em", to: :em
          map_element "strong", to: :strong
          map_element "sup", to: :sup
          map_element "sub", to: :sub
        end
      end

      # Expression of a term designation.
      class TermExpression < Lutaml::Model::Serializable
        attribute :name, TermNameElement, collection: true
        attribute :usage, :string
        attribute :abbreviation_type, :string

        xml do
          element "expression"
          map_element "name", to: :name
          map_element "usage", to: :usage
          map_element "abbreviation-type", to: :abbreviation_type
        end
      end
    end
  end
end
