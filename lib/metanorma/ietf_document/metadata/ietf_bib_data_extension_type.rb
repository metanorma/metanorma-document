# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module IetfDocument
    module Metadata
      class PiSettings < Lutaml::Model::Serializable
        attribute :toc, :string
        attribute :tocdepth, :string
        attribute :symrefs, :string
        attribute :sortrefs, :string
        attribute :compact, :string
        attribute :subcompact, :string
        attribute :strict, :string
        attribute :comments, :string
        attribute :notedraftinprogress, :string

        xml do
          element "pi"
          map_element "toc", to: :toc
          map_element "tocdepth", to: :tocdepth
          map_element "symrefs", to: :symrefs
          map_element "sortrefs", to: :sortrefs
          map_element "compact", to: :compact
          map_element "subcompact", to: :subcompact
          map_element "strict", to: :strict
          map_element "comments", to: :comments
          map_element "notedraftinprogress", to: :notedraftinprogress
        end
      end

      class IetfBibDataExtensionType < Lutaml::Model::Serializable
        attribute :doctype, :string
        attribute :flavor, :string
        attribute :ipr, :string
        attribute :consensus, :string
        attribute :area, :string, collection: true
        attribute :submission_type, :string
        attribute :editorial_group, IetfEditorialGroup
        attribute :pi, PiSettings

        xml do
          element "ext"
          map_element "doctype", to: :doctype
          map_element "flavor", to: :flavor
          map_element "ipr", to: :ipr
          map_element "consensus", to: :consensus
          map_element "area", to: :area
          map_element "submissionType", to: :submission_type
          map_element "editorial-group", to: :editorial_group
          map_element "editorialgroup", to: :editorial_group
          map_element "pi", to: :pi
        end
      end
    end
  end
end
