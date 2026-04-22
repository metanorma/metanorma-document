# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Encoding of region with ISO 3166 encoding.
      class RegionType < Lutaml::Model::Serializable
        attribute :iso, :string
        attribute :recommended, :boolean
        attribute :content, :string

        xml do
          map_attribute "iso", to: :iso
          map_attribute "recommended", to: :recommended
          map_content to: :content
        end
      end
    end
  end
end
