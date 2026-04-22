# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Hierarchical arrangement of bibliographic localities.
      class LocalityStack < Lutaml::Model::Serializable
        attribute :connective, :string
        attribute :bib_locality, BibItemLocality, collection: true

        xml do
          element "localityStack"
          map_attribute "connective", to: :connective
          map_element "locality", to: :bib_locality
        end
      end
    end
  end
end
