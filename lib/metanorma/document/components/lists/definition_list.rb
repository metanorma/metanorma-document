# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        # Definition list, composed of definitions rather than list items.
        class DefinitionList < List
          attribute :id, :string
          attribute :semx_id, :string
          attribute :key, :string
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement
          attribute :dt, DtElement, collection: true
          attribute :dd, DdElement, collection: true
          attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement
          attribute :json_type, :string

          def json_type
            "dl"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "dt", to: :dt
            map "dd", to: :dd
          end

          xml do
            element "dl"
            ordered
            map_attribute "id", to: :id
            map_attribute "semx-id", to: :semx_id
            map_attribute "key", to: :key
            map_element "name", to: :name
            map_element "dt", to: :dt
            map_element "dd", to: :dd
            map_element "fmt-name", to: :fmt_name
          end
        end
      end
    end
  end
end
