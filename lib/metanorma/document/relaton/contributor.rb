# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The contributor involved in the production of a bibliographic item; may be either a person or an
  # organization.
  class Contributor < Core::Node
    include Core::Node::Custom

    register_element
  end
end; end; end
