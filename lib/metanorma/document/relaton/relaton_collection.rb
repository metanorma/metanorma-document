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
  end
end; end; end
