# frozen_string_literal: true

require "metanorma/standard_document"

module Metanorma
  module IsoDocument
    autoload :AnnotationContainer, "metanorma/iso_document/annotation_container"
    autoload :Blocks, "metanorma/iso_document/blocks"
    autoload :Boilerplate, "metanorma/iso_document/boilerplate"
    autoload :Metadata, "metanorma/iso_document/metadata"
    autoload :RawParagraph, "metanorma/iso_document/raw_paragraph"
    autoload :Root, "metanorma/iso_document/root"
    autoload :Sections, "metanorma/iso_document/sections"
    autoload :Terms, "metanorma/iso_document/terms"
  end
end
