# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Model for formattedAddress element which may contain mixed content with <br/> tags.
      class FormattedAddress < Lutaml::Model::Serializable
        attribute :content, :string, collection: true
        attribute :br, Metanorma::Document::Components::Inline::BrElement,
                  collection: true

        xml do
          element "formattedAddress"
          mixed_content
          map_content to: :content
          map_element "br", to: :br
        end

        # Construct a FormattedAddress from an array of text lines,
        # inserting <br/> elements between them for proper mixed-content
        # serialization.
        def self.from_lines(lines)
          new.tap do |fa|
            fa.content = lines
            fa.br = lines[1..].map do
              Metanorma::Document::Components::Inline::BrElement.new
            end
          end
        end
      end

      # An address for a person or organization.
      class Address < Lutaml::Model::Serializable
        attribute :formatted_address_attr, :string
        attribute :formatted_address, FormattedAddress
        attribute :street, :string, collection: true
        attribute :city, :string
        attribute :state, :string
        attribute :country, :string
        attribute :postcode, :string

        xml do
          element "address"
          map_attribute "formatted-address", to: :formatted_address_attr
          map_element "formattedAddress", to: :formatted_address
          map_element "street", to: :street
          map_element "city", to: :city
          map_element "state", to: :state
          map_element "country", to: :country
          map_element "postcode", to: :postcode
        end
      end
    end
  end
end
