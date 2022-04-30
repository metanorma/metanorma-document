# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # An identifier of an organization according to an international identifier scheme.
  class OrgIdentifier < Core::Node
    include Core::Node::Custom

    register_element do
      # The international identifier scheme for the identifier of the organization.
      # Examples include GRID, LEI, CrossRef, and Ringgold.
      attribute :type, String

      # The identifier value.
      attribute :value, String
    end
  end
end; end; end
