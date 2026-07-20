# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Contact information for a person or organization.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 has no Contact
      # model class — its Contact mixin inlines phone/email/address/uri
      # directly on Person/Organization (the fixture shape), so there is no
      # counterpart to inherit. The <contact> wrapper appears in no fixture;
      # kept because the Person and Organization mappings declare it.
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
