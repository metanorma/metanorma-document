# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Used to present a group of bibliographic items as a single group.
  #
  # [example]
  # When summarising the collection of standards created by a standards body.
  #
  # A collection may be used for bibliographic exchange but is
  # typically not necesary for citation purposes.
  class RelatonCollection < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of grouping of bibliographic items.
      attribute :type, String

      # The title given to the grouping of bibliographic items.
      nodes :title, TypedTitleString

      # Contributors to the production of the bibliographic items as a grouping,
      # with corporate responsibility for all the items in the group (e.g. as compilers
      # of a collection or corporate authors).
      nodes :contributor, ContributionInfo

      # The individual items which constitute the group, expressed as relations to the
      # document group. The `type` attribute
      # of each relation is expected to be either `includes` or `hasPart`,
      # depending on whether the items exist as independent documents, or
      # are parts of a multi-part document.
      nodes :relation, DocumentRelation
    end
  end
end; end; end
