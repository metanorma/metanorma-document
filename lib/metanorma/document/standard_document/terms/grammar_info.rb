# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Grammatical information about a designation.
  class GrammarInfo < Core::Node
    include Core::Node::Custom

    register_element do
      # The grammatical gender of the designation.
      nodes :gender, GrammarGender

      # The designation is a preposition.
      nodes :is_preposition, TrueClass

      # The designation is a participle.
      nodes :is_participle, TrueClass

      # The designation is an adjective.
      nodes :is_adjective, TrueClass

      # The designation is a verb.
      nodes :is_verb, TrueClass

      # The designation is an adverb.
      nodes :is_adverb, TrueClass

      # The designation is a noun.
      nodes :is_noun, TrueClass
    end
  end
end; end; end
