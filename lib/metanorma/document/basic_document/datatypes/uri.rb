# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Container for URIs, as defined by <<rfc3986>>.
  class Uri < Core::Node::DataType
    include Core::Node::Custom
  end
end; end; end
