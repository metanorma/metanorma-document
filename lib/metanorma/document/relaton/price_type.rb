# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The price set on accessing the bibliographic item.
  class PriceType < Core::Node
    include Core::Node::Custom

    register_element do
      # The currency denomination for the price.
      attribute :currency, Iso4217Code

      # The currency amount for the price.
      attribute :content, String
    end
  end
end; end; end
