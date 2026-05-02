# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Model for formattedAddress element which may contain mixed content with <br/> tags.
      class FormattedAddress < Lutaml::Model::Serializable
        attribute :content, :string, collection: true

        xml do
          element "formattedAddress"
          map_content to: :content
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
