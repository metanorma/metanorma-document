# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Type of a media file.
  class MediaType < Core::Node::DataType
    # Value of the type of a media file. The BasicDocument model leaves the text to be used here open, but
    # recommends the use of MIME types.
  end
end; end; end
