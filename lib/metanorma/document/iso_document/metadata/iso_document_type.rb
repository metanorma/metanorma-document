# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Type of ISO/IEC document.
  class IsoDocumentType < Core::Node::Enum
    # International Standard.
    INTERNATIONAL_STANDARD = new("internationalStandard")

    # Technical Specification.
    TECHNICAL_SPECIFICATION = new("technicalSpecification")

    # Technical Report.
    TECHNICAL_REPORT = new("technicalReport")

    # Publicly Available Specification.
    PUBLICLY_AVAILABLE_SPECIFICATION = new("publiclyAvailableSpecification")

    # International Workshop Agreement.
    INTERNATIONAL_WORKSHOP_AGREEMENT = new("internationalWorkshopAgreement")

    # Guide.
    GUIDE = new("guide")

    # Interpretation Sheet.
    INTERPRETATION_SHEET = new("interpretationSheet")

    # Amendment.
    AMENDMENT = new("amendment")

    # Technical Corrigendum.
    TECHNICAL_CORRIGENDUM = new("technical-corrigendum")
  end
end; end; end
