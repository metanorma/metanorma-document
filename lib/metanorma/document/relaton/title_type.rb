# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Type of title given to a bibliographic item.
      class TitleType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "title-type"
          map_content to: :value
        end

        def self.values
          %w[alternative original unofficial subtitle main]
        end
      end
    end
  end
end
