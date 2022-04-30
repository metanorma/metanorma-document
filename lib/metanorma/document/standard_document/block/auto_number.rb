# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Specification of how blocks of a given class should be autonumbered
  # within an AmendBlock newContent element.
  class AutoNumber < Core::Node
    include Core::Node::Custom

    register_element do
      # The class of block to apply autonumbering to within an AmendBlock newContent element.
      attribute :type, ElementName

      # The starting value of numbering for the blocks with that class.
      attribute :value, String
    end
  end
end; end; end
