# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Specification of how blocks of a given class should be autonumbered
  # within an AmendBlock newContent element.
  class AutoNumber < Core::Node
    include Core::Node::Custom
  end
end; end; end
