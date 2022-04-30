# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Editorial group set up in ISO or IEC to work on producing documents.
  class IsoSubGroup < Core::Node
    include Core::Node::Custom

    register_element do
      # Type of editorial group.
      attribute :type, String

      # Number used to identify editorial group.
      attribute :number, Integer

      # Prefix used to differentiate editorial group for others of its class.
      attribute :prefix, String

      # Full identifier used to identify editorial group.
      attribute :identifier, String

      # Name of editorial group.
      attribute :name, String
    end
  end
end; end; end
