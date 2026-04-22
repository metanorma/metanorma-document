# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module DataTypes
      # String which is formatted according to conventions specified
      # in a named MIME type (<<rfc2046>>).
      class FormattedString < Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :type, :string

        xml do
          map_attribute "type", to: :type
        end
      end
    end
  end
end
