# frozen_string_literal: true

module Metanorma
  module Mko
    module Schema
      # collection.json — the family contract for collection bundles:
      # membership and cross-document edges between documents that a
      # metanorma collection.yml declares together (OIML R 60 parts,
      # R 129/138/144 families).
      class CollectionMember < Lutaml::Model::Serializable
        attribute :bundle, :string
        attribute :docidentifier, :string
        attribute :identifier, :string
        attribute :title, :string
        attribute :edition, :string

        json do
          map "bundle", to: :bundle
          map "docidentifier", to: :docidentifier
          map "identifier", to: :identifier
          map "title", to: :title
          map "edition", to: :edition
        end
      end

      class Collection < Lutaml::Model::Serializable
        attribute :canonical, :string
        attribute :short, :string
        attribute :title, :string
        attribute :edition, :string
        attribute :members, CollectionMember, collection: true,
                                              default: -> { [] }

        json do
          map "canonical", to: :canonical
          map "short", to: :short
          map "title", to: :title
          map "edition", to: :edition
          map "members", to: :members
        end
      end
    end
  end
end
