# frozen_string_literal: true

require "metanorma/document"

module Metanorma
  module StandardDocument
    autoload :Blocks, "metanorma/standard_document/blocks"
    autoload :Elements, "metanorma/standard_document/elements"
    autoload :Lists, "metanorma/standard_document/lists"
    autoload :Metadata, "metanorma/standard_document/metadata"
    autoload :Namespace, "metanorma/standard_document/namespace"
    autoload :Refs, "metanorma/standard_document/refs"
    autoload :Root, "metanorma/standard_document/root"
    autoload :Sections, "metanorma/standard_document/sections"
    autoload :StandardDocumentType,
             "metanorma/standard_document/standard_document_type"
    autoload :Terms, "metanorma/standard_document/terms"
  end
end
