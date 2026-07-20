# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      # Person associated with a bibliographic item.
      # Inherits relaton-bib's Person (gaining credential and address);
      # all mappings are re-declared with Metanorma's richer model classes —
      # relaton-bib 2.2.0.pre.alpha.1 sanitizes affiliation descriptions,
      # has no contact wrapper, and types uri as a collection.
      class Person < ::Relaton::Bib::Person
        attribute :name, FullName
        attribute :affiliation, Affiliation, collection: true
        attribute :identifier, PersonIdentifier, collection: true
        attribute :contact, ContactMethod, collection: true
        attribute :phone, Phone, collection: true
        attribute :email, :string, collection: true
        attribute :uri, TypedUri

        xml do
          map_element "name", to: :name
          map_element "affiliation", to: :affiliation
          map_element "identifier", to: :identifier
          map_element "contact", to: :contact
          map_element "phone", to: :phone
          map_element "email", to: :email
          map_element "uri", to: :uri
        end
      end
    end
  end
end
