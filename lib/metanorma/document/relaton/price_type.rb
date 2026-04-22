# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The price set on accessing the bibliographic item.
      class PriceType < Lutaml::Model::Serializable
        attribute :currency, :string
        attribute :content, :string

        xml do
          map_attribute "currency", to: :currency
          map_content to: :content
        end
      end
    end
  end
end
