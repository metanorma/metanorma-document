# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        class SourceOrigin < Lutaml::Model::Serializable
          attribute :bibitemid, :string
          attribute :type, :string
          attribute :citeas, :string
          attribute :locality_stack, Metanorma::Document::Relaton::LocalityStack,
                    collection: true
          attribute :display_text,
                    Metanorma::Document::Components::Inline::DisplayTextElement

          xml do
            element "origin"
            map_attribute "bibitemid", to: :bibitemid
            map_attribute "type", to: :type
            map_attribute "citeas", to: :citeas
            map_element "localityStack", to: :locality_stack
            map_element "display-text", to: :display_text
          end
        end

        class SourceModification < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true

          xml do
            element "modification"
            map_attribute "id", to: :id
            map_element "p", to: :p
          end
        end

        class SourceElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :status, :string
          attribute :type, :string
          attribute :origin, SourceOrigin
          attribute :modification, SourceModification

          xml do
            element "source"
            map_attribute "id", to: :id
            map_attribute "status", to: :status
            map_attribute "type", to: :type
            map_element "origin", to: :origin
            map_element "modification", to: :modification
          end
        end
      end
    end
  end
end
