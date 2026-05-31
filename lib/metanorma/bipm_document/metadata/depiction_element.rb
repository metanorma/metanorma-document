# frozen_string_literal: true

module Metanorma
  module BipmDocument
    module Metadata
      class DepictionElement < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          element "depiction"
          map_attribute "type", to: :type
          map_all_content to: :content
        end
      end
    end
  end
end
