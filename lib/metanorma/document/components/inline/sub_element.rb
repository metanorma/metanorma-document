# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class SubElement < Lutaml::Model::Serializable
          attribute :content, :string
          attribute :sub, SubElement, collection: true
          xml do
            element "sub"
            map_content to: :content
            map_element "sub", to: :sub
          end
        end
      end
    end
  end
end
