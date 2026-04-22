# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Blocks
      # Reference origin within a block source: <origin bibitemid="..." citeas="...">
      # Schema: isodoc.rnc — origin = element origin { erefType | termref }
      class SourceOriginElement < Lutaml::Model::Serializable
        attribute :bibitemid, :string
        attribute :type, :string
        attribute :citeas, :string
        attribute :locality_stack, Metanorma::Document::Relaton::LocalityStack,
                  collection: true

        xml do
          element "origin"
          map_attribute "bibitemid", to: :bibitemid
          map_attribute "type", to: :type
          map_attribute "citeas", to: :citeas
          map_element "localityStack", to: :locality_stack
        end
      end

      # Bibliographic source for a block: <source status="..." type="...">
      #   <origin bibitemid="..." citeas="..."/>
      #   <modification>...</modification>?
      # </source>
      # Schema: isodoc.rnc BlockSource = source*
      class BlockSourceElement < Lutaml::Model::Serializable
        attribute :status, :string
        attribute :type, :string
        attribute :origin, SourceOriginElement
        attribute :modification, Metanorma::Document::Components::Paragraphs::ParagraphBlock

        xml do
          element "source"
          map_attribute "status", to: :status
          map_attribute "type", to: :type
          map_element "origin", to: :origin
          map_element "modification", to: :modification
        end
      end
    end
  end
end
