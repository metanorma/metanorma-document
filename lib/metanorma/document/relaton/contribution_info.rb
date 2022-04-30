# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Description of a contributor to the production of the bibliographic item.
  class ContributionInfo < Core::Node
    include Core::Node::Custom

    register_element do
      # A description of the role of the contributor in the production of the bibliographic item.
      nodes :role, ContributorRole

      # The contributor involved in the production of the bibliographic item.
      node :entity, Contributor
    end
  end
end; end; end
