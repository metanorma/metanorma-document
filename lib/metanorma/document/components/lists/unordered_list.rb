# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        # Unordered list block.
        class UnorderedList < List
          attribute :id, :string
          attribute :semx_id, :string
          attribute :original_id, :string
          attribute :nobullet, :string
          attribute :spacing, :string
          attribute :indent, :string
          attribute :bare, :string
          attribute :json_type, :string

          def json_type
            "ul"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "listitem", to: :listitem
          end

          xml do
            element "ul"
            map_attribute "id", to: :id
            map_attribute "semx-id", to: :semx_id
            map_attribute "original-id", to: :original_id
            map_attribute "nobullet", to: :nobullet
            map_attribute "spacing", to: :spacing
            map_attribute "indent", to: :indent
            map_attribute "bare", to: :bare
          end
        end
      end
    end
  end
end
