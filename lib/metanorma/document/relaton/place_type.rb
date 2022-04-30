# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Place associated with the production of a bibliographic item.
  class PlaceType < Core::Node
    include Core::Node::Custom

    register_element do
      # Region or country within which the place is located, given for disambiguation purposes.
      #
      # Using an ISO 3166 code for a country or subnational region is recommended.
      attribute :region, String

      # URI in a geographical registry identifying the place.
      attribute :uri, String

      # Name of the place, not broken down.
      attribute :content, String
    end
  end
end; end; end
