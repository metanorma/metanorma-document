# frozen_string_literal: true

module Metanorma
  module BasicDocument
    # The basic document flavor, containing the most fundamental elements of a
    # Metanorma document, without any specific structure or semantics.
    autoload :AncillaryBlocks, "metanorma/basic_document/ancillary_blocks"
    autoload :BibData, "metanorma/basic_document/bib_data"
    autoload :Blocks, "metanorma/basic_document/blocks"
    autoload :Change, "metanorma/basic_document/change"
    autoload :ContribMetadata, "metanorma/basic_document/contrib_metadata"
    autoload :DataTypes, "metanorma/basic_document/data_types"
    autoload :EmptyElements, "metanorma/basic_document/empty_elements"
    autoload :IdElements, "metanorma/basic_document/id_elements"
    autoload :Lists, "metanorma/basic_document/lists"
    autoload :MultiParagraph, "metanorma/basic_document/multi_paragraph"
    autoload :Paragraphs, "metanorma/basic_document/paragraphs"
    autoload :ReferenceElements, "metanorma/basic_document/reference_elements"
    autoload :Sections, "metanorma/basic_document/sections"
    autoload :Tables, "metanorma/basic_document/tables"
    autoload :TextElements, "metanorma/basic_document/text_elements"
  end
end
