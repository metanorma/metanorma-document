# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Categories of IEC standards document.
  class IecDocumentCategory < Core::Node::Enum
    # Electromagnetic Compatibility (EMC).
    EMC = new("emc")

    # Safety.
    SAFETY = new("safety")

    # Environment.
    ENVIRONMENT = new("environment")

    # Quality Assurance.
    QUALITY_ASSURANCE = new("quality-assurance")
  end
end; end; end
