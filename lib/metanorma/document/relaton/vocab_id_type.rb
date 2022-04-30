# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Item in a controlled vocabulary.
  class VocabIdType < Core::Node
    include Core::Node::Custom

    register_element do
      # A label for the controlled vocabulary.
      attribute :type, String

      # A URI for the controlled vocabulary item.
      attribute :uri, BasicDocument::Uri

      # The code or identifier for the controlled vocabulary item.
      attribute :code, String

      # The term itself for the controlled vocabulary item.
      node :term, VocabIdType
    end
  end
end; end; end
