# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module IdElements
      # Container for audio content.
      class Audio < Metanorma::BasicDocument::IdElements::Media
        attribute :altsource, Metanorma::BasicDocument::IdElements::AltSource,
                  collection: true

        xml do
          element "audio"
          map_element "alt-source", to: :altsource
        end
      end
    end
  end
end
