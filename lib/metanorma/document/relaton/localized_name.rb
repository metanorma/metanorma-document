# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A name element with optional language and script attributes.
      class LocalizedName < Lutaml::Model::Serializable
        attribute :language, :string
        attribute :script, :string
        attribute :content, :string, collection: true

        xml do
          element "name"
          mixed_content
          map_attribute "language", to: :language
          map_attribute "script", to: :script
          map_content to: :content
        end
      end
    end
  end
end
