# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The phone number associated with a person or organization.
  class Phone < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of phone number; can include "Fax" and "Mobile".
      attribute :type, String

      # The phone number itself.
      attribute :content, String
    end
  end
end; end; end
