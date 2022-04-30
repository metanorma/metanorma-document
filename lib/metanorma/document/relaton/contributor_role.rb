# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # A description of the role of the contributor in the production of a bibliographic item.
  class ContributorRole < Core::Node
    include Core::Node::Custom

    register_element do
      # The broad class of role of the contributor.
      attribute :type, BasicObject # But actually: ContributorRoleType

      # A more detailed description of the role of the contributor.
      nodes :description, BasicDocument::FormattedString
    end
  end
end; end; end
