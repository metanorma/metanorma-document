# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      class LogoElement < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          element "logo"
          map_attribute "type", to: :type
          map_all_content to: :content
        end
      end
    end
  end
end
