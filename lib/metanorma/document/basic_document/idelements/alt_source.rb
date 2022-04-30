# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Alternative file to use as media.
  class AltSource < Core::Node
    include Core::Node::Custom

    register_element do
      # File name corresponding to the media, to which the media can be extracted if it is represented
      # inline (e.g. in Base64 encoding in the URI).
      attribute :filename, String

      # URI of the media file.
      attribute :source, Uri

      # Type of the media file.
      attribute :type, MediaType, xml_attribute: "mimetype"
    end
  end
end; end; end
