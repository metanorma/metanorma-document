# frozen_string_literal: true

module Metanorma
  module Mko
    module Schema
      # glossary.json — the document's local term entries.
      class GlossaryTerm < Lutaml::Model::Serializable
        attribute :unit, :string
        attribute :concept, :string
        attribute :designations, :string, collection: true, default: -> { [] }
        attribute :definition, :string
        attribute :sources, :string, collection: true, default: -> { [] }

        json do
          map "unit", to: :unit
          map "concept", to: :concept
          map "designations", to: :designations
          map "definition", to: :definition
          map "sources", to: :sources
        end
      end

      class Glossary < Lutaml::Model::Serializable
        attribute :terms, GlossaryTerm, collection: true

        json do
          map "terms", to: :terms
        end
      end
    end
  end
end
