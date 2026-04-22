# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The phone number associated with a person or organization.
      class Phone < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          map_attribute "type", to: :type
          map_content to: :content
        end
      end
    end
  end
end
