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
          end
        end
      end
    end
  end
end
