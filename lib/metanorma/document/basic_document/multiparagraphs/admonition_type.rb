# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Subclass of admonition determining how it is to be rendered.
  class AdmonitionType < Core::Node::Enum
    # Warning to reader, note of risk to be avoided.
    WARNING = new("warning")

    # Supplementary, explanatory information.
    NOTE = new("note")

    # Instructive information to assist in the fulfilment of tasks related to content.
    TIP = new("tip")

    # Note to reader of something crucial to be borne in mind.
    IMPORTANT = new("important")

    # Caution to reader, note of potential surprise or difficulty.
    CAUTION = new("caution")

    # Intended for typographically separate statements in mathematics, such as propositions, proofs, or
    # theorems. Statement conflates all of these for rendering, while Proposition, Proof, Theorem etc. can
    # be treated as distinct classes.
    STATEMENT = new("statement")
  end
end; end; end
