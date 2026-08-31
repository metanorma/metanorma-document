# frozen_string_literal: true

module Metanorma
  module Mko
    module Schema
      class TableColumn < Lutaml::Model::Serializable
        attribute :label, :string
        attribute :unit, :string

        json do
          map "label", to: :label
          map "unit", to: :unit
        end
      end

      class TablePayload < Lutaml::Model::Serializable
        attribute :caption, :string
        attribute :columns, TableColumn, collection: true
        attribute :rows, :string, collection: true, default: -> { [] }
        # The block's native JSON object — the Mirror node tree
        # (lossless; the serialization the JS renderer consumes).
        # Provenance/fidelity, not an embedding form: the retrieval
        # contract is the typed text fields.
        attribute :mirror, :hash

        json do
          map "caption", to: :caption
          map "columns", to: :columns
          map "rows", to: :rows
          map "mirror", to: :mirror
        end

        def embed_text
          cols = columns.map { |c| c.label + (c.unit ? " [#{c.unit}]" : "") }
            .join(", ")
          "Table: #{caption}; columns: #{cols}; " +
            rows.map { |r| "row: #{r}" }.join(" | ")
        end
      end

      class FormulaPayload < Lutaml::Model::Serializable
        attribute :asciimath, :string
        attribute :mathml, :string
        attribute :latex, :string
        attribute :omml, :string
        attribute :description, :string

        json do
          map "asciimath", to: :asciimath
          map "mathml", to: :mathml
          map "latex", to: :latex
          map "omml", to: :omml
          map "description", to: :description
        end
      end

      class FigurePayload < Lutaml::Model::Serializable
        attribute :alt, :string
        attribute :uri, :string
        # hash-addressed bundle asset ("assets/<sha256>"), when bytes
        # were available at export (data URIs or assets_from)
        attribute :asset, :string
        attribute :caption, :string
        # Native JSON object: the Mirror node tree (see TablePayload).
        attribute :mirror, :hash

        json do
          map "alt", to: :alt
          map "asset", to: :asset
          map "uri", to: :uri
          map "caption", to: :caption
          map "mirror", to: :mirror
        end
      end

      class TermSourceEntry < Lutaml::Model::Serializable
        attribute :citeas, :string

        json do
          map "citeas", to: :citeas
        end
      end

      class TermPayload < Lutaml::Model::Serializable
        attribute :concept, :string
        attribute :designations, :string, collection: true, default: -> { [] }
        attribute :admitted, :string, collection: true, default: -> { [] }
        attribute :deprecated, :string, collection: true, default: -> { [] }
        attribute :definition, :string
        attribute :sources, TermSourceEntry, collection: true, default: -> { [] }

        json do
          map "concept", to: :concept
          map "designations", to: :designations
          map "admitted", to: :admitted, render_empty: false
          map "deprecated", to: :deprecated, render_empty: false
          map "definition", to: :definition
          map "sources", to: :sources
        end
      end

      class RequirementPayload < Lutaml::Model::Serializable
        attribute :identifier, :string
        attribute :klass, :string
        attribute :obligation, :string
        attribute :subject, :string
        attribute :statement, :string
        attribute :inherits, :string, collection: true, default: -> { [] }

        json do
          map "identifier", to: :identifier
          map "class", to: :klass
          map "obligation", to: :obligation
          map "subject", to: :subject
          map "statement", to: :statement
          map "inherits", to: :inherits
        end
      end

      class ReferencePayload < Lutaml::Model::Serializable
        attribute :key, :string
        attribute :cited, :string

        json do
          map "key", to: :key
          map "cited", to: :cited
        end
      end

      # One knowledge object. payload is one of the typed payloads above,
      # chosen by type. text is the human-readable display text.
      class Unit < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :type, :string
        attribute :anchor, :string
        attribute :number, :string
        # the anchor a READER cites (issue #50 follow-up 2): the parent
        # clause number for embedded objects (tables/formulas/figures),
        # the unit's own number for top-level sections. Consumers cite
        # identically without walking the parent chain.
        attribute :cite_as, :string
        attribute :title, :string
        attribute :parent, :string
        attribute :breadcrumb, :string, collection: true, default: -> { [] }
        attribute :obligation, :string
        attribute :lang, :string
        # authoring-time situating note (#53 item 7): AI-assisted,
        # editor-approved, versioned with the document. Wire-ready —
        # emitted the day the authoring system ships it.
        attribute :ai_note, :string
        attribute :text, :string
        attribute :payload, :hash
        attribute :hash, :string

        json do
          map "id", to: :id
          map "type", to: :type
          map "anchor", to: :anchor
          map "number", to: :number
          map "cite_as", to: :cite_as
          map "title", to: :title
          map "parent", to: :parent
          map "breadcrumb", to: :breadcrumb
          map "obligation", to: :obligation
          map "lang", to: :lang
          map "ai_note", to: :ai_note, render_nil: false
          map "text", to: :text
          map "payload", to: :payload
          map "hash", to: :hash
        end
      end
    end
  end
end
