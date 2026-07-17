# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # A `<span>` wraps arbitrary inline content for styling or
        # classification. It accepts the full inline vocabulary — see
        # `Inline::Vocabulary` for the rationale.
        class SpanElement < Lutaml::Model::Serializable
          include Inline::Vocabulary

          attribute :class_attr, :string
          attribute :style, :string
          attribute :callout,
                    Metanorma::Document::Components::ReferenceElements::Callout,
                    collection: true

          xml do
            element "span"
            mixed_content
            map_attribute "class", to: :class_attr
            map_attribute "style", to: :style
            map_content to: :text
            map_element "callout", to: :callout
            Vocabulary::VocabularyXmlMapping.apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
