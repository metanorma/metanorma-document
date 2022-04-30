# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Container encoding the contribution made by a party towards a particular element in the document
  class ContributionElementMetadata < Core::Node
    include Core::Node::Custom

    register_element do
      # The date and time when the contribution was made
      attribute :date_time, Iso8601DateTime

      # The party who made the contribution, as described through the `contributor` element in Relaton.
      node :contributor, Relaton::Contributor

      # A digital signature of the contribution.
      nodes :integrity_value, BasicObject # But actually: integrityValue
    end
  end
end; end; end
