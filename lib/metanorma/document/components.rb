# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      autoload :AncillaryBlocks,
               "metanorma/document/components/ancillary_blocks"
      autoload :BibData, "metanorma/document/components/bib_data"
      autoload :Blocks, "metanorma/document/components/blocks"
      autoload :Change, "metanorma/document/components/change"
      autoload :ContribMetadata,
               "metanorma/document/components/contrib_metadata"
      autoload :DataTypes, "metanorma/document/components/data_types"
      autoload :EmptyElements, "metanorma/document/components/empty_elements"
      autoload :IdElements, "metanorma/document/components/id_elements"
      autoload :Lists, "metanorma/document/components/lists"
      autoload :MultiParagraph, "metanorma/document/components/multi_paragraph"
      autoload :Paragraphs, "metanorma/document/components/paragraphs"
      autoload :ReferenceElements,
               "metanorma/document/components/reference_elements"
      autoload :Sections, "metanorma/document/components/sections"
      autoload :Tables, "metanorma/document/components/tables"
      autoload :Inline, "metanorma/document/components/inline"
      autoload :TextElements, "metanorma/document/components/text_elements"
    end
  end
end
