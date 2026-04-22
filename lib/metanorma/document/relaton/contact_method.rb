# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Contact information for a person or organization.
      class ContactMethod < Lutaml::Model::Serializable
        attribute :address, Metanorma::Document::Relaton::Address
        attribute :phone, Metanorma::Document::Relaton::Phone, collection: true
        attribute :email, :string
        attribute :uri, Metanorma::Document::Relaton::TypedUri

        xml do
          map_element "address", to: :address
          map_element "phone", to: :phone
          map_element "email", to: :email
          map_element "uri", to: :uri
        end
      end
    end
  end
end
