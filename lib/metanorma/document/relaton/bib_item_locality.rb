# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The extent or location of a bibliographic item being referred to.
      class BibItemLocality < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :reference_from, :string
        attribute :reference_to, :string

        xml do
          element "locality"
          map_attribute "type", to: :type
          map_element "referenceFrom", to: :reference_from
          map_element "referenceTo", to: :reference_to
        end
      end
    end
  end
end
