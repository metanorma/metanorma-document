# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The type of change described in AmendBlock.
  class ChangeType < Core::Node::Enum
    # Indicates a change that adds content.
    ADD = new("add")

    # Indicates a change that modifies existing content.
    MODIFY = new("modify")

    # Indicates a change that deletes content.
    DELETE = new("delete")
  end
end; end; end
