# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Contact information for a person or organization.
  class ContactMethod < Core::Node
    include Core::Node::Custom

    register_element do
      # Address.
      node :address, Address

      # Telephone number.
      nodes :phone, Phone

      # Email address.
      attribute :email, String

      # URI.
      node :uri, TypedUri
    end
  end
end; end; end
