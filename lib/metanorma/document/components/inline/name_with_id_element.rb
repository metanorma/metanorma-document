# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class NameWithIdElement < Lutaml::Model::Serializable
          include Inline::Vocabulary

          attribute :id, :string
          attribute :anchor, :string
          attribute :semx_id, :string

          xml do
            element "name"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_content to: :text
            Vocabulary::VocabularyXmlMapping.apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
