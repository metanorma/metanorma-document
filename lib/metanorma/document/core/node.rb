# frozen_string_literal: true

require_relative "node/mixin"
require_relative "node/custom"
require_relative "node/generic"
require_relative "node/comment"

module Metanorma; module Document; module Core
  # The top ancestors of all nodes. It won't ever be created directly.
  # This is so that gems can inherit from it, so that they can create
  # their own API.
  #
  # All the implementation of a Node is located in a Mixin module. This
  # module can be included directly if you wish for a different class
  # hierarchy.
  class Node
    include Mixin
  end
end; end; end
