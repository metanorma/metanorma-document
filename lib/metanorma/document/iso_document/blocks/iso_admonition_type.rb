# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Types of admonition specific to ISO/IEC.
  class IsoAdmonitionType < Core::Node::Enum
    # Danger.
    DANGER = new("danger")

    # Caution.
    CAUTION = new("caution")

    # Warning.
    WARNING = new("warning")

    # Important.
    IMPORTANT = new("important")

    # Safety Precautions.
    SAFETY_PRECAUTIONS = new("safetyPrecautions")
  end
end; end; end
