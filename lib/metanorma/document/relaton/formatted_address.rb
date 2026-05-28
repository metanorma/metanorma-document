# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      class FormattedAddress < Lutaml::Model::Serializable
        attribute :content, :string, collection: true
        attribute :br, Metanorma::Document::Components::Inline::BrElement,
                  collection: true

        xml do
          element "formattedAddress"
          mixed_content
          map_content to: :content
          map_element "br", to: :br
        end

        def self.from_lines(lines)
          new.tap do |fa|
            fa.content = lines
            fa.br = lines[1..].map do
              Metanorma::Document::Components::Inline::BrElement.new
            end
          end
        end
      end
    end
  end
end
