# frozen_string_literal: true

module Metanorma
  module Mko
    module Schema
      class Ids < Lutaml::Model::Serializable
        attribute :canonical, :string
        attribute :short, :string
        attribute :docid, :string, collection: true
        attribute :urn, :string, collection: true

        json do
          map "canonical", to: :canonical
          map "short", to: :short
          map "docid", to: :docid
          map "urn", to: :urn
        end
      end

      class TitleEntry < Lutaml::Model::Serializable
        attribute :lang, :string
        attribute :text, :string

        json do
          map "lang", to: :lang
          map "text", to: :text
        end
      end

      class DateEntry < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :on, :string

        json do
          map "type", to: :type
          map "on", to: :on
        end
      end

      class StatusInfo < Lutaml::Model::Serializable
        attribute :stage, :string
        attribute :substage, :string
        attribute :abbreviation, :string

        json do
          map "stage", to: :stage
          map "substage", to: :substage
          map "abbreviation", to: :abbreviation
        end
      end

      class RelationEntry < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :to, :string

        json do
          map "type", to: :type
          map "to", to: :to
        end
      end

      class StructureNode < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :number, :string
        attribute :title, :string
        attribute :children, StructureNode, collection: true,
                  default: -> { [] }

        json do
          map "id", to: :id
          map "number", to: :number
          map "title", to: :title
          map "children", to: :children
        end
      end

      # document.json — identity, status, and the numbered structure tree.
      class Document < Lutaml::Model::Serializable
        attribute :ids, Ids
        attribute :flavor, :string
        attribute :doctype, :string
        attribute :titles, TitleEntry, collection: true
        attribute :edition, :string
        attribute :languages, :string, collection: true
        attribute :status, StatusInfo
        attribute :dates, DateEntry, collection: true
        attribute :relations, RelationEntry, collection: true
        attribute :structure, StructureNode, collection: true

        json do
          map "ids", to: :ids
          map "flavor", to: :flavor
          map "doctype", to: :doctype
          map "titles", to: :titles
          map "edition", to: :edition
          map "languages", to: :languages
          map "status", to: :status
          map "dates", to: :dates
          map "relations", to: :relations
          map "structure", to: :structure
        end
      end
    end
  end
end
