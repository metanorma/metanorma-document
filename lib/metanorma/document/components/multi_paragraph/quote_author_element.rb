# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module MultiParagraph
        class QuoteAuthorElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :text, :string

          xml do
            element "author"
            map_attribute "id", to: :id
            map_content to: :text
          end
        end
      end
    end
  end
end
