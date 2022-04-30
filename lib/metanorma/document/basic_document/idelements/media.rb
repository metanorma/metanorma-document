# frozen_string_literal: true

require "basic_document/idelements/id_element"

module Metanorma; module Document; module BasicDocument
  # Container for media content.
  class Media < IdElement
    register_element do
      # File name corresponding to the media, to which the media can be extracted if it is represented
      # inline (e.g. in Base64 encoding in the URI).
      attribute :filename, String

      # URI of the media file.
      attribute :source, Uri, xml_attribute: "src"

      # Type of the media file.
      attribute :type, MediaType, xml_attribute: "mimetype"

      # Alternate text, supplied for accessibility.
      attribute :alt, String

      # Title, supplied for accessibility.
      attribute :title, String

      # URI pointing to more extensive alternate text description, supplied for accessibility.
      attribute :longdesc, Uri
    end
  end
end; end; end
