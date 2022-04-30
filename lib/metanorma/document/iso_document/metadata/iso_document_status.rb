# frozen_string_literal: true

require "metanorma/document/relaton/document_status"

module Metanorma; module Document; module IsoDocument
  # Publication status of an ISO/IEC document.
  class IsoDocumentStatus < Relaton::DocumentStatus
    register_element do
      # Publication stage of the ISO/IEC document, expressed as an International Harmonized Stage Code.
      attribute :stage, IsoDocumentStageCodes

      # Standard abbreviation of the publication stage.
      attribute :stage_abbreviation, String

      # Substage code for the ISO/IEC document.
      attribute :substage, IsoDocumentSubstageCodes

      # Standard abbreviation of the publication substage.
      attribute :substage_abbreviation, String

      # Number of the iteration of the publication stage that the document is in.
      attribute :iteration, Integer
    end
  end
end; end; end
