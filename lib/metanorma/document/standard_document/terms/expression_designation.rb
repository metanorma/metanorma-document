# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # A designation realised as a linguistic form.
  class ExpressionDesignation < Core::Node
    include Core::Node::Custom

    register_element "expression" do
      # The language of the designation, as an ISO-639 3-letter code.
      attribute :language, BasicDocument::Iso639Code

      # The script of the designation, as an ISO-15924 code.
      attribute :script, BasicDocument::Iso15924Code

      # Type of linguistic form used as designation.
      attribute :type, ExpressionType

      # The textual form of the designation.
      nodes :text, String

      # A pronunciation guide to the designation.
      nodes :pronunciation, BasicDocument::LocalizedString

      # Whether the designation (typically an abbreviation) is the same across languages, or
      # language-specific.
      attribute :is_international, TrueClass

      # Type of abbreviation, according to how it is formed.
      attribute :abbreviation_type, AbbreviationType

      # Grammatical information about the designation.
      node :grammar_info, GrammarInfo
    end
  end
end; end; end
