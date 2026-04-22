# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Information about the medium and transmission of a bibliographic item.
      class MediumType < Lutaml::Model::Serializable
        attribute :content, :string
        attribute :genre, :string
        attribute :form, :string
        attribute :carrier, :string
        attribute :size, :string
        attribute :scale, :string

        xml do
          map_attribute "content", to: :content
          map_attribute "genre", to: :genre
          map_attribute "form", to: :form
          map_attribute "carrier", to: :carrier
          map_attribute "size", to: :size
          map_attribute "scale", to: :scale
        end
      end
    end
  end
end
