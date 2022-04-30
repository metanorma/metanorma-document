# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # A group associated with the production of the standards document, typically within
  # a standards definition organization.
  class EditorialGroupType < Core::Node
    include Core::Node::Custom

    register_element do
      # A technical committee associated with the production of the standards document.
      nodes :technicalcommittee, TechnicalCommitteeType
    end
  end
end; end; end
