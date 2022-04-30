# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Classification taken from the International Classification of Standards.
  # ICS is defined by ISO here -- https://www.iso.org/publication/PUB100033.html
  class IcsType < Core::Node
    include Core::Node::Custom
  end
end; end; end
