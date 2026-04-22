# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module IdElements
        # Type of a media file.
        class MediaType < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "media-type"
            map_content to: :value
          end
        end
      end
    end
  end
end
