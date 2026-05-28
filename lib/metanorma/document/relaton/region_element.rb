# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      class RegionElement < Lutaml::Model::Serializable
        attribute :iso, :string
        attribute :content, :string

        xml do
          element "region"
          map_attribute "iso", to: :iso
          map_content to: :content
        end
      end
    end
  end
end
