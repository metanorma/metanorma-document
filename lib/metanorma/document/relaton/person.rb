# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Person associated with a bibliographic item.
      class Person < Contributor
        attribute :name, FullName
        attribute :affiliation, Affiliation, collection: true
        attribute :identifier, PersonIdentifier, collection: true
        attribute :contact, ContactMethod, collection: true
        attribute :phone, Phone, collection: true
        attribute :email, :string, collection: true

        xml do
          map_element "name", to: :name
          map_element "affiliation", to: :affiliation
          map_element "identifier", to: :identifier
          map_element "contact", to: :contact
          map_element "phone", to: :phone
          map_element "email", to: :email
        end
      end
    end
  end
end
