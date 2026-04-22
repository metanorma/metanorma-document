# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Place associated with the production of a bibliographic item.
      # Region element with iso attribute.
      class RegionElement < Lutaml::Model::Serializable
        attribute :iso, :string
        attribute :content, :string

        xml do
          element "region"
          map_attribute "iso", to: :iso
          map_content to: :content
        end
      end

      class PlaceType < Lutaml::Model::Serializable
        attribute :region_attr, :string
        attribute :region, RegionElement
        attribute :city, :string
        attribute :uri, :string
        attribute :content, :string

        xml do
          map_attribute "region", to: :region_attr
          map_attribute "uri", to: :uri
          map_element "region", to: :region
          map_element "city", to: :city
          map_content to: :content
        end
      end
    end
  end
end
