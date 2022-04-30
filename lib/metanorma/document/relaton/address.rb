# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # An address for a person or organization.
  class Address < Core::Node
    include Core::Node::Custom

    register_element do
      # Preformatted version of the address, not decomposed into its component parts.
      #
      # NOTE: `formattedAddress` is mutually exclusive with `street`, `city`, `state`, `country`, and
      # `postcode`.
      attribute :formatted_address, String

      # The street and street number or equivalent in the address.
      nodes :street, String

      # The settlement or municipality in the address.
      attribute :city, String

      # The region of the country in the address.
      attribute :state, String

      # The country in the address.
      attribute :country, String

      # The postal code or equivalent in the address.
      attribute :postcode, String
    end
  end
end; end; end
