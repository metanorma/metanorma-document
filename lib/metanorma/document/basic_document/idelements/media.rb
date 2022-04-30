# frozen_string_literal: true

require "basic_document/idelements/id_element"

module Metanorma; module Document; module BasicDocument
  # Container for media content.
  class Media < IdElement
    register_element do
      # File name corresponding to the media, to which the media can be extracted if it is represented
      # inline (e.g. in Base64 encoding in the URI).
      nodes :filename, String

      # URI of the media file.
      attribute :source, Uri

      # Type of the media file.
      node :type, MediaType

      # Alternate text, supplied for accessibility.
      nodes :alt, String

      # Title, supplied for accessibility.
      nodes :title, String

      # URI pointing to more extensive alternate text description, supplied for accessibility.
      nodes :longdesc, Uri
    end
  end
end; end; end
