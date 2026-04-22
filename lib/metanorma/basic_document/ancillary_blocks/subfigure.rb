# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module AncillaryBlocks
      # A figure embedded within another figure.
      # Subfigures only occur within figures.
      class Subfigure < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "subfigure"
          map_content to: :value
        end
      end
    end
  end
end
