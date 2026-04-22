# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Significant date in the lifecycle of the bibliographic item.
      class BibliographicDate < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :format, :string
        attribute :text, :string
        attribute :from, DateTime
        attribute :to, DateTime
        attribute :on, DateTime

        xml do
          element "date"
          map_attribute "type", to: :type
          map_attribute "format", to: :format
          map_content to: :text
          map_element "from", to: :from
          map_element "to", to: :to
          map_element "on", to: :on
        end
      end
    end
  end
end
