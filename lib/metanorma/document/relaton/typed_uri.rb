# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # URI associated with a type.
      class TypedUri < Metanorma::Document::Components::DataTypes::Uri
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
