# frozen_string_literal: true

require "metanorma/document/basic_document/bibdata/bib_data"

module Metanorma; module Document; module StandardDocument
  # The bibliographic description of a _StandardDocument_.
  class StandardBibData < BasicDocument::BibData
    register_element do
      # The extension point of the bibliographic description of a _StandardDocument_.
      node :ext, StandardBibDataExtensionType
    end
  end
end; end; end
