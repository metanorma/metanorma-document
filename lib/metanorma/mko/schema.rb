# frozen_string_literal: true

module Metanorma
  module Mko
    # The MKO wire schema. Every class is a lutaml-model Serializable with
    # JSON mappings — one schema, framework-generated serializations only.
    module Schema
      autoload :Manifest, "metanorma/mko/schema/manifest"
      autoload :Document, "metanorma/mko/schema/document"
      autoload :StructureNode, "metanorma/mko/schema/document"
      autoload :Unit, "metanorma/mko/schema/unit"
      autoload :Edge, "metanorma/mko/schema/edge"
      autoload :Identifiers, "metanorma/mko/schema/identifiers"
      autoload :JsonSchema, "metanorma/mko/schema/json_schema"
      autoload :IdentifierInfo, "metanorma/mko/schema/identifiers"
    end
  end
end
