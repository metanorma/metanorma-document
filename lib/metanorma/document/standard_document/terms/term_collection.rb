# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # A collection of terms, constituting the main body of a Terms Section.
  class TermCollection < Core::Node
    include Core::Node::Custom

    register_element do
      # Individual terms.
      nodes :terms, Term
    end
  end
end; end; end
