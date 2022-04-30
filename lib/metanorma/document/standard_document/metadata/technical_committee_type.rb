# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Technical committee associated with the production of a standards document.
  class TechnicalCommitteeType < Core::Node
    include Core::Node::Custom

    register_element "technical-committee" do
      # Identifier of the technical committee (typically numeric).
      attribute :number, Integer

      # Type of the technical committee, used in identifying the technical committee.
      attribute :type, String

      # Name of the technical committee.
      attribute :text, String
    end
  end
end; end; end
