# frozen_string_literal: true

module Metanorma
  module Mko
    module Schema
      # JSON Schema (draft 2020-12) generation for the MKO wire
      # contract. The lutaml schema classes are the single source of
      # truth: types come from the attribute declarations, wire names
      # from the classes' json mappings (e.g. :klass renders as
      # "class"). Consumers validate against these schemas — never
      # against hand-written copies that drift.
      module JsonSchema
        PRIMITIVES = {
          "Lutaml::Model::Type::String" => { "type" => "string" },
          "Lutaml::Model::Type::Integer" => { "type" => "integer" },
          "Lutaml::Model::Type::Boolean" => { "type" => "boolean" },
          "Lutaml::Model::Type::Hash" => { "type" => "object" },
        }.freeze

        class << self
          def schema_for(klass, seen = {})
            return { "$ref" => seen[klass] } if seen.key?(klass)

            seen[klass] = "#"
            properties = klass.attributes.each_with_object({}) do |(name, attr), h|
              h[wire_name(klass, name)] = property_for(attr, seen)
            end
            {
              "$schema" => "https://json-schema.org/draft/2020-12/schema",
              "title" => klass.name.to_s.split("::").last,
              "type" => "object",
              "properties" => properties,
            }
          end

          # The published contract: one schema per wire component and
          # per typed payload, plus the consumer excerpt.
          def all
            Unit # trigger payload-class autoloads
            schemas = {
              "unit" => schema_for(Unit),
              "edge" => schema_for(Edge),
              "manifest" => schema_for(Manifest),
              "document" => schema_for(Document),
              "identifiers" => schema_for(Identifiers),
              "collection" => schema_for(Schema::Collection),
              "payload-table" => schema_for(TablePayload),
              "payload-formula" => schema_for(FormulaPayload),
              "payload-figure" => schema_for(FigurePayload),
              "payload-term" => schema_for(TermPayload),
              "payload-requirement" => schema_for(RequirementPayload),
              "payload-reference" => schema_for(ReferencePayload),
            }
            schemas["excerpt"] = excerpt_schema(schemas)
            schemas
          end

          # Consumer clause: text with [[u:…]] references plus resolved
          # producer payload blocks (MN 116 §consumer-refs).
          def excerpt_schema(payload_schemas)
            block = {
              "type" => "object",
              "properties" => {
                "unit_id" => { "type" => "string", "pattern" => "\\Au:" },
                "type" => { "type" => "string" },
                "docidentifier" => { "type" => "string" },
                "edition" => { "type" => "string" },
                "payload" => {
                  "oneOf" => payload_schemas
                    .select { |name, _| name.start_with?("payload-") }
                    .map { |_, s| s },
                },
              },
              "required" => %w[unit_id type payload],
            }
            {
              "$schema" => "https://json-schema.org/draft/2020-12/schema",
              "title" => "Excerpt",
              "type" => "object",
              "properties" => {
                "text" => { "type" => "string" },
                "blocks" => { "type" => "array", "items" => block },
              },
              "required" => %w[text blocks],
            }
          end

          private

          def property_for(attr, seen)
            type = primitive(attr) || schema_for(attr.type, seen)
            attr.collection? ? { "type" => "array", "items" => type } : type
          end

          def primitive(attr)
            PRIMITIVES[attr.type.name.to_s]
          end

          # The json mappings are the wire contract; the attribute name
          # is only the Ruby-side handle.
          def wire_name(klass, attr_name)
            wire_names(klass)[attr_name] || attr_name.to_s
          end

          def wire_names(klass)
            @wire_names ||= {}
            @wire_names[klass] ||= begin
              mapping = klass.mappings_for(:json)
              mapping.mappings_hash.values.each_with_object({}) do |rule, h|
                h[rule.to] = rule.name.to_s
              end
            end
          end
        end
      end
    end
  end
end
