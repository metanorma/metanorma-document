# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The size of a bibliographic item being referred to.
      class BibItemSize < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :value, Metanorma::Document::Components::DataTypes::LocalizedString

        xml do
          element "bib-item-size"
          map_attribute "type", to: :type
          map_element "value", to: :value
        end
      end
    end
  end
end
