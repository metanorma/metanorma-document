# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Item in a controlled vocabulary.
      class VocabIdType < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :uri, :string
        attribute :code, :string
        attribute :term, Metanorma::Document::Relaton::VocabIdType

        xml do
          map_attribute "type", to: :type
          map_attribute "uri", to: :uri
          map_attribute "code", to: :code
          map_element "term", to: :term
        end
      end
    end
  end
end
