# frozen_string_literal: true

module Metanorma
  module Mko
    module Schema
      class ManifestComponent < Lutaml::Model::Serializable
        attribute :name, :string
        attribute :file, :string
        attribute :media_type, :string
        attribute :count, :integer
        attribute :hash, :string

        json do
          map "name", to: :name
          map "file", to: :file
          map "media_type", to: :media_type
          map "count", to: :count
          map "hash", to: :hash
        end
      end

      class Generated < Lutaml::Model::Serializable
        attribute :tool, :string
        attribute :schema_version, :string
        attribute :flavor, :string
        attribute :timestamp, :string

        json do
          map "tool", to: :tool
          map "schema_version", to: :schema_version
          map "flavor", to: :flavor
          map "timestamp", to: :timestamp
        end
      end

      class Manifest < Lutaml::Model::Serializable
        attribute :schema, :string
        attribute :schema_version, :string
        attribute :generated, Generated
        attribute :source_file, :string
        attribute :source_hash, :string
        attribute :components, ManifestComponent, collection: true
        attribute :license, :string
        attribute :copyright, :string

        json do
          map "schema", to: :schema
          map "schema_version", to: :schema_version
          map "generated", to: :generated
          map "source", to: :source_file
          map "source-hash", to: :source_hash
          map "components", to: :components
          map "license", to: :license
          map "copyright", to: :copyright
        end
      end
    end
  end
end
