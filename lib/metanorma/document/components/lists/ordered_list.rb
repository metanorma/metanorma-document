# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        # Ordered list, with numbering applied to the list items.
        class OrderedList < UnorderedList
          attribute :type, :string
          attribute :start, :string
          attribute :semx_id, :string
          attribute :displayorder, :integer
          attribute :display, :string
          attribute :display_directives, :string
          attribute :class_attr, :string

          def json_type
            "ol"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "listitem", to: :listitem
          end

          xml do
            element "ol"
            map_attribute "id", to: :id
            map_attribute "type", to: :type
            map_attribute "semx-id", to: :semx_id
            map_attribute "displayorder", to: :displayorder
            map_attribute "display", to: :display
            map_attribute "display-directives", to: :display_directives
            map_attribute "class", to: :class_attr, render_empty: true
            map_attribute "start", to: :start
          end
        end
      end
    end
  end
end
