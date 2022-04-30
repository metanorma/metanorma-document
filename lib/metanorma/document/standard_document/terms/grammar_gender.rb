# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The grammatical gender of the designation.
  class GrammarGender < Core::Node::Enum
    # Masculine gender.
    MASCULINE = new("masculine")

    # Feminine gender.
    FEMININE = new("feminine")

    # Neuter gender.
    NEUTER = new("neuter")

    # Masculine + Feminine gender.
    COMMON = new("common")
  end
end; end; end
