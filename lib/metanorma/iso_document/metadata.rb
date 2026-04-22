# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Metadata
      autoload :AbstractTitle, "#{__dir__}/metadata/abstract_title"
      autoload :DocIdentifier, "#{__dir__}/metadata/doc_identifier"
      autoload :IecDocumentCategory, "#{__dir__}/metadata/iec_document_category"
      autoload :IsoBibDataExtensionType,
               "#{__dir__}/metadata/iso_bib_data_extension_type"
      autoload :IsoBibliographicItem,
               "#{__dir__}/metadata/iso_bibliographic_item"
      autoload :IsoDocumentId, "#{__dir__}/metadata/iso_document_id"
      autoload :IsoDocumentStageCodes,
               "#{__dir__}/metadata/iso_document_stage_codes"
      autoload :IsoDocumentStatus, "#{__dir__}/metadata/iso_document_status"
      autoload :IsoDocumentSubstageCodes,
               "#{__dir__}/metadata/iso_document_substage_codes"
      autoload :IsoDocumentType, "#{__dir__}/metadata/iso_document_type"
      autoload :IsoLocalizedTitle, "#{__dir__}/metadata/iso_localized_title"
      autoload :TitleCollection, "#{__dir__}/metadata/title_collection"
      autoload :IsoProjectGroup, "#{__dir__}/metadata/iso_project_group"
      autoload :IsoSubGroup, "#{__dir__}/metadata/iso_sub_group"
      autoload :TitleFull, "#{__dir__}/metadata/title_full"
      autoload :TitleIntro, "#{__dir__}/metadata/title_intro"
      autoload :TitleMain, "#{__dir__}/metadata/title_main"
      autoload :TitlePart, "#{__dir__}/metadata/title_part"
      autoload :TitlePartPrefix, "#{__dir__}/metadata/title_part_prefix"
      autoload :TitleAmd, "#{__dir__}/metadata/title_amd"
      autoload :TitleAmendmentPrefix,
               "#{__dir__}/metadata/title_amendment_prefix"
      autoload :Ics, "#{__dir__}/metadata/ics"
      autoload :StructuredIdentifier,
               "#{__dir__}/metadata/structured_identifier"
      autoload :ProjectNumber, "#{__dir__}/metadata/structured_identifier"
      autoload :MetanormaExtension, "#{__dir__}/metadata/metanorma_extension"
    end
  end
end
