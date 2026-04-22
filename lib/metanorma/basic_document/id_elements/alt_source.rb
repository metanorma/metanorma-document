# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module IdElements
      # Alternative file to use as media.
      class AltSource < Lutaml::Model::Serializable
        attribute :filename, :string
        attribute :source, :string
        attribute :type, :string

        xml do
          element "alt-source"
          map_attribute "filename", to: :filename
          map_attribute "source", to: :source
          map_attribute "mimetype", to: :type
        end
      end
    end
  end
end
