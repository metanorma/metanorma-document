# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module IdElements
        # Container for audio content.
        class Audio < Media
          attribute :altsource, AltSource, collection: true

          xml do
            element "audio"
            map_element "alt-source", to: :altsource
          end
        end
      end
    end
  end
end
