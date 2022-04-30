# frozen_string_literal: true

require "standard_document/metadata/standard_bib_data_extension_type"

module Metanorma; module Document; module IsoDocument
  # Extension point for bibliographical definitions of ISO/IEC documents.
  class IsoBibDataExtensionType < StandardDocument::StandardBibDataExtensionType
  end
end; end; end
