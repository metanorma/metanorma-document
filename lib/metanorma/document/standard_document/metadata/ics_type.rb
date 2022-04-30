# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Classification taken from the International Classification of Standards.
  # ICS is defined by ISO here -- https://www.iso.org/publication/PUB100033.html
  class IcsType < Core::Node
    include Core::Node::Custom

    register_element do
      # Classification code taken from the ICS.
      attribute :code, String

      # Text string associated with the classification code.
      nodes :text, String
    end
  end
end; end; end
