# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      # Text with Ruby annotations in East Asian languages. Corresponds to HTML `ruby`.
      class RubyElement < Metanorma::BasicDocument::TextElements::TextElement
        attribute :ruby_paren,
                  Metanorma::Document::Components::DataTypes::LocalizedString, collection: true
        attribute :ruby_text,
                  Metanorma::Document::Components::DataTypes::LocalizedString, collection: true

        xml do
          element "ruby"
          map_element "rp", to: :ruby_paren
          map_element "rt", to: :ruby_text
        end
      end
    end
  end
end
