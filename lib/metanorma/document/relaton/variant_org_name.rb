# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # A variant name of an organization.
  class VariantOrgName < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of variant name for the organization.
      attribute :type, String

      # The variant name itself.
      node :content, BasicDocument::LocalizedString
    end
  end
end; end; end
