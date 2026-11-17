# frozen_string_literal: true

module Metanorma
  module Document
    module Elements
      class Label < Lutaml::Model::Serializable
        include Metanorma::Document::Components::Inline::Vocabulary

        attribute :for_attr, :string

        xml do
          element "label"
          mixed_content
          map_attribute "for", to: :for_attr
          map_content to: :text
          Metanorma::Document::Components::Inline::Vocabulary::VocabularyXmlMapping.apply_inline_mappings(self)
        end
      end
    end
  end
end
