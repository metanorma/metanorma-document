# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # A version of the bibliographic item (within an edition). Can be used for drafts.
  class VersionInfo < Core::Node
    include Core::Node::Custom

    register_element do
      # The date at which the current version of the bibliographic item was produced.
      attribute :revision_date, BasicDocument::Iso8601DateTime

      # The identifier for the current draft of the bibliographic item.
      attribute :draft, String
    end
  end
end; end; end
