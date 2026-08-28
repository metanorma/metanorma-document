# frozen_string_literal: true

module Metanorma
  module Mko
    module Schema
      # identifiers.json — the document's identifiers, with the pubid
      # parse when one succeeds.
      class IdentifierInfo < Lutaml::Model::Serializable
        attribute :original, :string
        attribute :type, :string
        attribute :primary, :boolean
        attribute :parsed, :string

        json do
          map "original", to: :original
          map "type", to: :type
          map "primary", to: :primary
          map "parsed", to: :parsed
        end
      end

      class Identifiers < Lutaml::Model::Serializable
        attribute :identifiers, IdentifierInfo, collection: true

        json do
          map "identifiers", to: :identifiers
        end
      end
    end
  end
end
