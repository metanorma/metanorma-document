# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Grammatical information about a designation.
  class GrammarInfo < Core::Node
    include Core::Node::Custom

    register_element do
      # The grammatical gender of the designation.
      nodes :gender, GrammarGender

      # The designation is a preposition.
      attribute :is_preposition, TrueClass

      # The designation is a participle.
      attribute :is_participle, TrueClass

      # The designation is an adjective.
      attribute :is_adjective, TrueClass

      # The designation is a verb.
      attribute :is_verb, TrueClass

      # The designation is an adverb.
      attribute :is_adverb, TrueClass

      # The designation is a noun.
      attribute :is_noun, TrueClass
    end
  end
end; end; end
