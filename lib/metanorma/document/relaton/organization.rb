# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      class Organization < Contributor
        attribute :name, LocalizedName, collection: true
        attribute :variant, VariantOrgName, collection: true
        attribute :subdivision, OrgSubdivision, collection: true
        attribute :variant_subdivision, VariantOrgName, collection: true
        attribute :abbreviation, :string
        attribute :uri, TypedUri, collection: true
        attribute :identifier, OrgIdentifier, collection: true
        attribute :contact, ContactMethod, collection: true
        attribute :logo, LogoElement, collection: true
        attribute :address, Address, collection: true

        xml do
          element "organization"
          map_element "name", to: :name
          map_element "variant", to: :variant
          map_element "subdivision", to: :subdivision
          map_element "variant-subdivision", to: :variant_subdivision
          map_element "abbreviation", to: :abbreviation
          map_element "uri", to: :uri
          map_element "identifier", to: :identifier
          map_element "contact", to: :contact
          map_element "logo", to: :logo
          map_element "address", to: :address
        end
      end
    end
  end
end
