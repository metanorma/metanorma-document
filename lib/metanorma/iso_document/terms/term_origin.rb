# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Terms
      # Origin reference in a term source.
      class TermOrigin < Lutaml::Model::Serializable
        attribute :bibitemid, :string
        attribute :type, :string
        attribute :citeas, :string
        attribute :locality_stack, Metanorma::Document::Relaton::LocalityStack,
                  collection: true
        attribute :display_text, Metanorma::Document::Components::Inline::DisplayTextElement

        xml do
          element "origin"
          map_attribute "bibitemid", to: :bibitemid
          map_attribute "type", to: :type
          map_attribute "citeas", to: :citeas
          map_element "localityStack", to: :locality_stack
          map_element "display-text", to: :display_text
        end
      end
    end
  end
end
