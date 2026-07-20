# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # An address of a person or organization.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Address has no
      # formatted-address attribute and types formattedAddress as a raw
      # string — fixtures carry structured formattedAddress content with
      # <br/> line breaks (ietf), kept queryable via FormattedAddress.
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
