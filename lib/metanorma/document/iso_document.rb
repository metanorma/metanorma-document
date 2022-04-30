# frozen_string_literal: true

module Metanorma; module Document
  # See: https://metanorma.org/
  module IsoDocument
  end
end; end

require_relative "iso_document/blocks/iso_admonition_block"
require_relative "iso_document/blocks/iso_admonition_type"
require_relative "iso_document/iso_amendment_document"
require_relative "iso_document/iso_standard_document"
require_relative "iso_document/metadata/iec_document_category"
require_relative "iso_document/metadata/iso_bib_data_extension_type"
require_relative "iso_document/metadata/iso_bibliographic_item"
require_relative "iso_document/metadata/iso_document_id"
require_relative "iso_document/metadata/iso_document_stage_codes"
require_relative "iso_document/metadata/iso_document_status"
require_relative "iso_document/metadata/iso_document_substage_codes"
require_relative "iso_document/metadata/iso_document_type"
require_relative "iso_document/metadata/iso_localized_title"
require_relative "iso_document/metadata/iso_project_group"
require_relative "iso_document/metadata/iso_sub_group"
require_relative "iso_document/sections/iso_amendment_clause"
require_relative "iso_document/sections/iso_annex_section"
require_relative "iso_document/sections/iso_preface"
require_relative "iso_document/sections/iso_sections"
require_relative "iso_document/terms/iso_term"
require_relative "iso_document/terms/iso_term_collection"
