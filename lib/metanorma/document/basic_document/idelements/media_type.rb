# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Type of a media file.
  class MediaType < Core::Node
    include Core::Node::Custom

    register_element do
      # Value of the type of a media file. The BasicDocument model leaves the text to be used here open, but
      # recommends the use of MIME types.
      attribute :content, String
    end
  end
end; end; end
