# frozen_string_literal: true

require "relaton/document_status"

module Metanorma; module Document; module IsoDocument
  # Publication status of an ISO/IEC document.
  class IsoDocumentStatus < Relaton::DocumentStatus
    register_element do
      # Publication stage of the ISO/IEC document, expressed as an International Harmonized Stage Code.
      attribute :stage, IsoDocumentStageCodes

      # Standard abbreviation of the publication stage.
      nodes :stage_abbreviation, String

      # Substage code for the ISO/IEC document.
      nodes :substage, IsoDocumentSubstageCodes

      # Standard abbreviation of the publication substage.
      nodes :substage_abbreviation, String

      # Number of the iteration of the publication stage that the document is in.
      nodes :iteration, Integer
    end
  end
end; end; end
