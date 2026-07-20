# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Geographic place of publication or production of a bibliographic item.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Place has no text
      # content and no +region+ attribute — the text of <place>Geneva</place>
      # (160 of 228 fixture place elements carry text) would serialize as
      # <place/>.
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
