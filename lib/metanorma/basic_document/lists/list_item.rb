# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Lists
      class ListItem < Lutaml::Model::Serializable
        attribute :content, :string, collection: true

        xml do
          element "listitem"
          mixed_content
          map_content to: :content
        end
      end
    end
  end
end
