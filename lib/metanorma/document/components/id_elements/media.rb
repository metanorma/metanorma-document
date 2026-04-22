# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module IdElements
        # Container for media content.
        class Media < IdElement
          # File name corresponding to the media, to which the media can be extracted if it is represented
          # inline (e.g. in Base64 encoding in the URI).
          attribute :filename, :string

          # URI of the media file.
          attribute :source, :string

          # Type of the media file.
          attribute :type, :string

          # Alternate text, supplied for accessibility.
          attribute :alt, :string

          # Title, supplied for accessibility.
          attribute :title, :string

          # URI pointing to more extensive alternate text description, supplied for accessibility.
          attribute :longdesc, :string

          xml do
            element "media"
            map_attribute "filename", to: :filename
            map_attribute "src", to: :source
            map_attribute "mimetype", to: :type
            map_attribute "alt", to: :alt, render_empty: true
            map_attribute "title", to: :title
            map_attribute "longdesc", to: :longdesc
          end
        end
      end
    end
  end
end
