# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Strikethrough text. Corresponds to HTML 4 `s`.
        # Contains mixed content with inline elements.
        class StrikeElement < Lutaml::Model::Serializable
          include Inline::Vocabulary
          attribute :text, :string, collection: true
          attribute :ruby, "Metanorma::Document::Components::TextElements::RubyElement",
                    collection: true

          xml do
            element "strike"
            mixed_content
            map_content to: :text
            Metanorma::Document::Components::Inline::Vocabulary::VocabularyXmlMapping.apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
