# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # An identifier of a person according to an international identifier scheme.
  class PersonIdentifier < Core::Node
    include Core::Node::Custom

    register_element do
      # The international identifier scheme for the identifier of the person.
      attribute :type, PersonalIdentifierType

      # The identifier value.
      attribute :value, String
    end
  end
end; end; end
