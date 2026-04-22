# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Edition of a bibliographic item.
      class Edition < Lutaml::Model::Serializable
        attribute :number, :string
        attribute :language, :string
        attribute :content, :string

        xml do
          element "edition"
          map_attribute "number", to: :number
          map_attribute "language", to: :language, render_empty: true
          map_content to: :content
        end
      end
    end
  end
end
