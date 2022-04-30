# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The affiliation of a person with an organization.
  class Affiliation < Core::Node
    include Core::Node::Custom

    register_element do
      # The name of the affiliation of the person with the organization;
      # typically a position title.
      node :name, BasicDocument::LocalizedString

      # A more detailed description of the affiliation of the person.
      nodes :description, BasicDocument::FormattedString

      # The organization with which the person is affiliated.
      node :organization, Organization
    end
  end
end; end; end
