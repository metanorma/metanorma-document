# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # A variant name of a person.
  class VariantFullName < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of variant name for the person. Examples include
      # pseudonyms; user names (online);
      # real names (if the person is named with a pseudonym or user name);
      # previous legal names.
      attribute :type, String

      # The variant name itself.
      node :content, FullName
    end
  end
end; end; end
